extension Ion.StructDecoder {
    @frozen public struct Field: ~Copyable {
        @usableFromInline let _base: Ion._FieldContext<CodingKey, Ion.SymbolError>
        @inlinable init(
            id: CodingKey,
            value: consuming Result<Ion.NodeDecoder, Ion.SymbolError>
        ) {
            self._base = .init(id: id, value: value)
        }
    }
}
extension Ion.StructDecoder.Field: Ion.FieldDecoder {
    @inline(always) @inlinable public func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        try self._base.decode(with: decode)
    }
}
