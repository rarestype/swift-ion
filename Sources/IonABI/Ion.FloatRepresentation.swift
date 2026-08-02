extension Ion {
    @frozen public enum FloatRepresentation {
        case float32(Float)
        case float64(Double)
    }
}
extension Ion.FloatRepresentation {
    public typealias NullGroup = Self
}
extension Ion.FloatRepresentation: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        switch self {
        case .float32(let self): self.encode(to: &ion)
        case .float64(let self): self.encode(to: &ion)
        }
    }
}
extension Ion.FloatRepresentation: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.float)
    }
}
extension Ion.FloatRepresentation: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .float }
}
