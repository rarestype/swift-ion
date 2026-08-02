import Ion

extension Roundtripping {
    enum Enum: String, IonEncodable, IonDecodable, CaseIterable {
        case foobie
        case barbie
    }
}
