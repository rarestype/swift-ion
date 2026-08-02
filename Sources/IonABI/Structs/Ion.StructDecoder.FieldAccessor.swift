extension Ion.StructDecoder {
    @frozen public struct FieldAccessor: ~Copyable {
        @usableFromInline let _base: Ion._FieldAccessor<CodingKey, Ion.SymbolError>
        @inlinable init(
            id: CodingKey,
            value: consuming Result<Ion.NodeDecoder?, Ion.SymbolError>
        ) {
            self._base = .init(id: id, value: value)
        }
    }
}
extension Ion.StructDecoder.FieldAccessor: Ion.FieldDecoder {
    @inline(always) @inlinable public func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        try self._base.decode(with: decode)
    }
}
