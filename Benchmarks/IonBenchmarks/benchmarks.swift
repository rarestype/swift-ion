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
}
