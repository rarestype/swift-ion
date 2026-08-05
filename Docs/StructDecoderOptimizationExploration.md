# StructDecoder performance optimization exploration

## Executive summary
This document records performance optimization experiments conducted on `Ion.StructDecoder` in `swift-ion`.

The primary goal of this investigation was to reduce or eliminate heap allocations caused by instantiations of the `[Symbol.ID: Node]` index table during `Ion.StructDecoder` initialization.

While we successfully eliminated **400,000 heap allocations** for 200,000 decoded structs using lazy inline field offset indexing, wall-clock latency regressed slightly (~3–4%) when decoding 100% of fields in a document due to the cost of scanning headers in Pass 1 and re-parsing value payloads on-demand in Pass 2.

---

## Benchmark baseline

- **Benchmark target**: `IonBenchmarks/Decode/Document` (200,000 `Document.Item` struct instances).
- **Baseline heap allocations**: ~1,202,000 allocations (~1,035 MB allocated).
- **Baseline wall-clock time**: ~281 ms.

---

## Experiments and findings

### 1. F14 deterministic hash maps
- **Idea**: Replace standard Swift `Dictionary` with Facebook-style F14 deterministic hashtable implementation.
- **Evaluation**: Rejected before implementation.
- **Rationale**:
    - F14 requires architecture-specific SIMD instructions (x86_64), breaking cross-platform portability (e.g. ARM64 / Apple Silicon / Linux AArch64).
    - Standard heap-allocated hash tables still incur bucket buffer allocations per struct instance.

### 2. Contiguous `[Entry]` indexing
- **Idea**: Replace `[Symbol.ID: Node]` dictionary with a contiguous `[(id: Symbol.ID, node: Node)]`.
- **Result**: Reduced allocations from **1,202,000 down to 1,002,000** (eliminated 200,000 hash bucket allocations).
- **Drawback**: `Array` still requires 1 heap allocation per struct decoder for its backing buffer header.

### 3. Fixed inline tuples of Ion.Node (InlineArray)
- **Idea**: Store a fixed inline tuple `(Ion.Node, Ion.Node, ...)` directly inside `StructIndex` to avoid heap allocations.
- **Result**: Abandoned due to Swift 6 runtime ABI constraints.
- **Drawback**:
    - `Ion.Node` is ~96 bytes in memory (contains large `AnyValue` enums with `ArraySlice<UInt8>` payloads).
    - Storing 8 inline nodes creates a 768-byte struct layout, causing stack coroutine frame inflation in `_read` accessors.

### 4. Lazy field offset indexing (Ion.Struct.Offsets + Ion.Struct.Index)
- **Idea**: Store small 32-byte field offset descriptors (`Ion.Struct.Index`: `id`, `offset`, `header`) instead of pre-parsing 96-byte `Ion.Node` values. Parse values lazily on-demand when subscript `ion[.field]` is queried.
- **Inline storage**: Used named inline fields (`f0...f3` or `f0...f7`) for structs with $\le 4$ or $\le 8$ fields, with a dictionary fallback for larger structs.

#### Metrics comparison

| Strategy | Total malloc count | Total malloc bytes | Wall-clock time (200k structs) |
| :--- | :--- | :--- | :--- |
| **Baseline (`[Symbol.ID: Node]`)** | 1,202,000 | 1,035 MB | **281 ms** |
| **Offset indexing (`ContiguousArray`)** | 1,002,000 | 1,002 MB | **281 ms** |
| **Offset indexing (`FixedArray4` inline)** | **802,000** | **1,025 MB** | **292 ms** |

#### Lessons and tradeoffs
1. **Allocation victory**: `FixedArray` inline field offset storage achieved **0 heap allocations per struct decoder instance** for structs with $\le 4$ fields, eliminating **400,000 heap allocations**.
2. **Wall-clock latency tradeoff**:
    - For **full-model decoding** (where all fields in a struct are read), lazy indexing performs two passes: Pass 1 scans headers to record byte offsets, and Pass 2 creates a temporary `Ion.Input` to parse the value payload on demand.
    - This double-scanning penalty added ~11 ms total latency (~55 nanoseconds per struct).
3. **When lazy indexing wins**:
    - Lazy indexing is advantageous when structs contain many optional/unused fields, as unread fields are never parsed.
    - For dense models where every field is decoded, single-pass eager parsing remains faster in wall-clock time despite higher memory allocation churn.

---

## Conclusion and recommendations

For dense data models where every struct field is decoded, single-pass eager parsing minimizes byte-stream traversals. Random-access field queries impose an inherent heap allocation cost, pushing things onto the stack simply shifts the overhead there instead.

Performant struct decoding must use `Ion.StructCursor` rather than `Ion.StructDecoder`, but this runs afoul of Swift’s strict definite initialization (DI) rules. Working around DI restrictions would likely involve defining a parallel model type for each struct, with all fields optionalized and initialized out-of-order before asserting field existence and transferring unwrapped values to a primary model type. Unfortunately this decoding pattern is extremely developer-unfriendly and requires significant handwritten boilerplate in order to achieve a comparable quality of error handling.
