import Benchmark
import Ion

let benchmarks: @Sendable () -> () = {
    Benchmark.init("Encode/Document") {
        let model: Document = .example

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let encoded: Ion = Ion.encode(atomic: model)
            blackHole(encoded)
        }
    }

    Benchmark.init("Decode/Document") {
        let model: Document = .example
        let ion: Ion = Ion.encode(atomic: model)

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let decoded: Document = try ion.decode()
            blackHole(decoded)
        }
    }

    Benchmark.init("Decode/Integers/UInt8") { benchmark in
        let model: Integers<UInt8> = .init(
            values: (0 ..< 100_000).map { UInt8.init(truncatingIfNeeded: $0) }
        )
        let ion: Ion = Ion.encode(atomic: model)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            let decoded: Integers<UInt8> = try ion.decode()
            blackHole(decoded)
        }
    }

    Benchmark.init("Decode/Integers/UInt16") { benchmark in
        let model: Integers<UInt16> = .init(
            values: (0 ..< 100_000).map { UInt16.init(truncatingIfNeeded: $0) }
        )
        let ion: Ion = Ion.encode(atomic: model)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            let decoded: Integers<UInt16> = try ion.decode()
            blackHole(decoded)
        }
    }

    Benchmark.init("Decode/Integers/UInt32") { benchmark in
        let model: Integers<UInt32> = .init(
            values: (0 ..< 100_000).map { UInt32.init(truncatingIfNeeded: $0 * 1_000_007) }
        )
        let ion: Ion = Ion.encode(atomic: model)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            let decoded: Integers<UInt32> = try ion.decode()
            blackHole(decoded)
        }
    }

    Benchmark.init("Decode/Integers/UInt64") { benchmark in
        let model: Integers<UInt64> = .init(
            values: (0 ..< 100_000).map { UInt64.init($0) * 1_000_000_007 }
        )
        let ion: Ion = Ion.encode(atomic: model)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            let decoded: Integers<UInt64> = try ion.decode()
            blackHole(decoded)
        }
    }
}
