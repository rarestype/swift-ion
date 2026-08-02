extension Never {
    public typealias NullGroup = Self
}
extension Never: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {}
}
extension Never: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        let _: Never = try ion.value.cast { _ in nil }
    }
}
extension Never: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .null }
}
