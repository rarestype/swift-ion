import Ion

extension Document {
    struct Item: Equatable {
        let id: Int
        let label: String?
        let value: Double

        init(id: Int, label: String, value: Double) {
            self.id = id
            self.label = label
            self.value = value
        }
    }
}
extension Document.Item {
    static func generate(count: Int) -> [Self] {
        (0 ..< count).map {
            .init(id: $0, label: "Item_\($0)", value: Double($0) * 1.5)
        }
    }
}
extension Document.Item {
    enum CodingKey: String, IonSymbolizable {
        case id
        case label
        case value
    }
}
extension Document.Item: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.id] = self.id
        ion[.label] = self.label
        ion[.value] = self.value == 0 ? nil : self.value
    }
}
extension Document.Item: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.id = try ion[.id].decode()
        self.label = try ion[.label]?.decode()
        self.value = try ion[.value]?.decode() ?? 0
    }
}
