import Ion

extension IonBenchmarks {
    struct DeepStruct: Equatable {
        let name: String
        let level1: Child
        let level2: Child

        init(name: String, level1: Child, level2: Child) {
            self.name = name
            self.level1 = level1
            self.level2 = level2
        }
    }
}
extension IonBenchmarks.DeepStruct {
    enum CodingKey: String, IonSymbolizable {
        case name
        case level1
        case level2
    }
}
extension IonBenchmarks.DeepStruct: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.name] = self.name
        ion[.level1] = self.level1
        ion[.level2] = self.level2
    }
}
extension IonBenchmarks.DeepStruct: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.name = try ion[.name]?.decode() ?? ""
        self.level1 = try ion[.level1].decode()
        self.level2 = try ion[.level2].decode()
    }
}
