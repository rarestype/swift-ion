import Ion

struct Document: Equatable {
    let id: Int
    let title: String
    let metadata: Metadata
    let tags: [String]
    let items: [Item]

    init(
        id: Int,
        title: String,
        metadata: Metadata,
        tags: [String],
        items: [Item]
    ) {
        self.id = id
        self.title = title
        self.metadata = metadata
        self.tags = tags
        self.items = items
    }
}
extension Document {
    static var example: Self {
        .init(
            id: 42,
            title: "Production Payload Benchmark Document",
            metadata: .init(
                owner: "BarbiefrontUSA",
                environment: "production",
                attributes: (0 ..< 1_000).map { "attribute_\($0)" }
            ),
            tags: (0 ..< 1_000).map { "tag_\($0)" },
            items: Item.generate(count: 200_000)
        )
    }
}
extension Document {
    enum CodingKey: String, IonSymbolizable {
        case id
        case title
        case metadata
        case tags
        case items
    }
}
extension Document: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.id] = self.id
        ion[.title] = self.title
        ion[.metadata] = self.metadata
        ion[.tags] = self.tags
        ion[.items] = self.items
    }
}
extension Document: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.id = try ion[.id]?.decode() ?? 0
        self.title = try ion[.title]?.decode() ?? ""
        self.metadata = try ion[.metadata].decode()
        self.tags = try ion[.tags]?.decode() ?? []
        self.items = try ion[.items]?.decode() ?? []
    }
}
