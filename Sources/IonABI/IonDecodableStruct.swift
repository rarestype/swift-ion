public protocol IonDecodableStruct<CodingKey>: IonDecodable where NullGroup == Ion.Struct {
    associatedtype CodingKey: IonSymbolizable
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws
}
extension IonDecodableStruct {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.bind(with: Self.init(ion:))
    }
}
