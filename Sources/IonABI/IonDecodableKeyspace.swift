public protocol IonDecodableKeyspace: IonDecodable where NullGroup == Ion.Struct {
    init(ion: inout Ion.StructCursor) throws
}
extension IonDecodableKeyspace {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.bind(with: Self.init(ion:))
    }
}
