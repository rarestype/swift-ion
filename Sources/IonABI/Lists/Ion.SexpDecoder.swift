extension Ion {
    @frozen @usableFromInline struct SexpDecoder: ~Copyable {
        @usableFromInline var list: ListDecoder
        @inlinable init(list: consuming ListDecoder) {
            self.list = list
        }
    }
}
extension Ion.SexpDecoder: Ion.Decoder {
    @inlinable static func acquire(context: consuming Ion.NodeDecoder) throws -> Self {
        .init(list: try .acquire(context: context))
    }
}
