import Ion

extension Document {
    struct Metadata: Equatable {
        let owner: String
        let environment: String
        let attributes: [String]

        init(owner: String, environment: String, attributes: [String]) {
            self.owner = owner
            self.environment = environment
            self.attributes = attributes
        }
    }
}
extension Document.Metadata {
    enum CodingKey: String, IonSymbolizable {
        case owner
        case environment
        case attributes
    }
}
extension Document.Metadata: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.owner] = self.owner
        ion[.environment] = self.environment
        ion[.attributes] = self.attributes
    }
}
extension Document.Metadata: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.owner = try ion[.owner].decode()
        self.environment = try ion[.environment].decode()
        self.attributes = try ion[.attributes]?.decode() ?? []
    }
}
