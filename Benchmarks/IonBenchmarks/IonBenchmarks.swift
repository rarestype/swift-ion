import Benchmark
import Ion

enum IonBenchmarks {}

let benchmarks: @Sendable () -> () = {
    Benchmark.init("StructsWithLists/Encode/WideStruct") {
        let model: IonBenchmarks.WideStruct = .init(
            id: 42,
            title: "Benchmark Test Payload",
            tags: ["swift", "ion", "binary", "benchmark", "serialization"],
            scores: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000],
            metadata: .init(
                owner: "Antigravity",
                attributes: ["production", "release", "v1"]
            )
        )

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let encoded: Ion = Ion.encode(atomic: model)
            blackHole(encoded)
        }
    }

    Benchmark.init("StructsWithLists/Decode/WideStruct") {
        let model: IonBenchmarks.WideStruct = .init(
            id: 42,
            title: "Benchmark Test Payload",
            tags: ["swift", "ion", "binary", "benchmark", "serialization"],
            scores: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000],
            metadata: .init(
                owner: "Antigravity",
                attributes: ["production", "release", "v1"]
            )
        )
        let ion: Ion = Ion.encode(atomic: model)

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let decoded: IonBenchmarks.WideStruct = try ion.decode(atomic: IonBenchmarks.WideStruct.self)
            blackHole(decoded)
        }
    }

    Benchmark.init("NestedStructs/Encode/DeepStruct") {
        let model: IonBenchmarks.DeepStruct = .init(
            name: "Root",
            level1: .init(name: "Level1", depth: 1),
            level2: .init(name: "Level2", depth: 2)
        )

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let encoded: Ion = Ion.encode(atomic: model)
            blackHole(encoded)
        }
    }

    Benchmark.init("NestedStructs/Decode/DeepStruct") {
        let model: IonBenchmarks.DeepStruct = .init(
            name: "Root",
            level1: .init(name: "Level1", depth: 1),
            level2: .init(name: "Level2", depth: 2)
        )
        let ion: Ion = Ion.encode(atomic: model)

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let decoded: IonBenchmarks.DeepStruct = try ion.decode(atomic: IonBenchmarks.DeepStruct.self)
            blackHole(decoded)
        }
    }

    Benchmark.init("ListOfStructs/Encode/StructList") {
        let items: [IonBenchmarks.StructList.Item] = (0 ..< 100).map { i in
            .init(id: i, label: "Item_\(i)", value: Double(i) * 1.5)
        }
        let model: IonBenchmarks.StructList = .init(category: "Catalog", items: items)

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let encoded: Ion = Ion.encode(atomic: model)
            blackHole(encoded)
        }
    }

    Benchmark.init("ListOfStructs/Decode/StructList") {
        let items: [IonBenchmarks.StructList.Item] = (0 ..< 100).map { i in
            .init(id: i, label: "Item_\(i)", value: Double(i) * 1.5)
        }
        let model: IonBenchmarks.StructList = .init(category: "Catalog", items: items)
        let ion: Ion = Ion.encode(atomic: model)

        $0.startMeasurement()
        for _ in $0.scaledIterations {
            let decoded: IonBenchmarks.StructList = try ion.decode(atomic: IonBenchmarks.StructList.self)
            blackHole(decoded)
        }
    }
}

