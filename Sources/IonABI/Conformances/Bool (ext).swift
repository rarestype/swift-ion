extension Bool {
    public typealias NullGroup = Self
}
extension Bool: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[bool: self]
    }
}
extension Bool: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.bool)
    }
}
extension Bool: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .bool }
}
