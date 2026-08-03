extension Ion.ListDecoder {
    @frozen public struct FieldAccessor: ~Copyable {
        @usableFromInline let _base: Ion._FieldAccessor<Int, Ion.InputError>
        @inlinable init(
            id: Int,
            value: consuming Result<Ion.NodeDecoder?, Ion.InputError>
        ) {
            self._base = .init(id: id, value: value)
        }
    }
}
extension Ion.ListDecoder.FieldAccessor {
    @inlinable public var id: Int { self._base.id }
}
extension Ion.ListDecoder.FieldAccessor: Ion.FieldDecoder {
    @inline(always) @inlinable public func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        try self._base.decode(with: decode)
    }
}
