import Ion

extension IonBenchmarks.DeepStruct {
    struct Child: Equatable {
        let name: String
        let depth: Int

        init(name: String, depth: Int) {
            self.name = name
            self.depth = depth
        }
    }
}
extension IonBenchmarks.DeepStruct.Child {
    enum CodingKey: String, IonSymbolizable {
        case name
        case depth
    }
}
extension IonBenchmarks.DeepStruct.Child: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.name] = self.name
        ion[.depth] = self.depth
    }
}
extension IonBenchmarks.DeepStruct.Child: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.name = try ion[.name]?.decode() ?? ""
        self.depth = try ion[.depth]?.decode() ?? 0
    }
}
