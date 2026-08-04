import Ion

extension IonBenchmarks {
    struct StructList: Equatable {
        let category: String
        let items: [Item]

        init(category: String, items: [Item]) {
            self.category = category
            self.items = items
        }
    }
}
extension IonBenchmarks.StructList {
    enum CodingKey: String, IonSymbolizable {
        case category
        case items
    }
}
extension IonBenchmarks.StructList: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.category] = self.category
        ion[.items] = self.items
    }
}
extension IonBenchmarks.StructList: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.category = try ion[.category]?.decode() ?? ""
        self.items = try ion[.items]?.decode() ?? []
    }
}
