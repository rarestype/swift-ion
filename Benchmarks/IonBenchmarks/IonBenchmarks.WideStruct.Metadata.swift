import Ion

extension IonBenchmarks.WideStruct {
    struct Metadata: Equatable {
        let owner: String
        let attributes: [String]

        init(owner: String, attributes: [String]) {
            self.owner = owner
            self.attributes = attributes
        }
    }
}
extension IonBenchmarks.WideStruct.Metadata {
    enum CodingKey: String, IonSymbolizable {
        case owner
        case attributes
    }
}
extension IonBenchmarks.WideStruct.Metadata: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.owner] = self.owner
        ion[.attributes] = self.attributes
    }
}
extension IonBenchmarks.WideStruct.Metadata: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.owner = try ion[.owner]?.decode() ?? ""
        self.attributes = try ion[.attributes]?.decode() ?? []
    }
}
