import Ion

extension IonBenchmarks {
    struct WideStruct: Equatable {
        let id: Int
        let title: String
        let tags: [String]
        let scores: [Int]
        let metadata: Metadata

        init(
            id: Int,
            title: String,
            tags: [String],
            scores: [Int],
            metadata: Metadata
        ) {
            self.id = id
            self.title = title
            self.tags = tags
            self.scores = scores
            self.metadata = metadata
        }
    }
}
extension IonBenchmarks.WideStruct {
    enum CodingKey: String, IonSymbolizable {
        case id
        case title
        case tags
        case scores
        case metadata
    }
}
extension IonBenchmarks.WideStruct: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.id] = self.id
        ion[.title] = self.title
        ion[.tags] = self.tags
        ion[.scores] = self.scores
        ion[.metadata] = self.metadata
    }
}
extension IonBenchmarks.WideStruct: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.id = try ion[.id]?.decode() ?? 0
        self.title = try ion[.title]?.decode() ?? ""
        self.tags = try ion[.tags]?.decode() ?? []
        self.scores = try ion[.scores]?.decode() ?? []
        self.metadata = try ion[.metadata].decode()
    }
}
