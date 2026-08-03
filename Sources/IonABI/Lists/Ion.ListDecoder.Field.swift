extension Ion.ListDecoder {
    @frozen public struct Field: ~Copyable {
        @usableFromInline let _base: Ion._FieldContext<Int, Ion.InputError>
        @inlinable init(
            id: Int,
            value: consuming Result<Ion.NodeDecoder, Ion.InputError>
        ) {
            self._base = .init(id: id, value: value)
        }
    }
}
extension Ion.ListDecoder.Field {
    @inlinable public var id: Int { self._base.id }
}
extension Ion.ListDecoder.Field: Ion.FieldDecoder {
    @inline(always) @inlinable public func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        try self._base.decode(with: decode)
    }
}
