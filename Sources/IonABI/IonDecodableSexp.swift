public protocol IonDecodableSexp: IonDecodable where NullGroup == Ion.Sexp {
    init(ion: inout Ion.ListDecoder) throws
}
extension IonDecodableSexp {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.bind(to: Ion.SexpDecoder.self) { try .init(ion: &$0.list) }
    }
}
