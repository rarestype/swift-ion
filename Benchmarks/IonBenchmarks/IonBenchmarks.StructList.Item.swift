import Ion

extension IonBenchmarks.StructList {
    struct Item: Equatable {
        let id: Int
        let label: String
        let value: Double

        init(id: Int, label: String, value: Double) {
            self.id = id
            self.label = label
            self.value = value
        }
    }
}
extension IonBenchmarks.StructList.Item {
    enum CodingKey: String, IonSymbolizable {
        case id
        case label
        case value
    }
}
extension IonBenchmarks.StructList.Item: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.id] = self.id
        ion[.label] = self.label
        ion[.value] = self.value
    }
}
extension IonBenchmarks.StructList.Item: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.id = try ion[.id]?.decode() ?? 0
        self.label = try ion[.label]?.decode() ?? ""
        self.value = try ion[.value]?.decode() ?? 0.0
    }
}
