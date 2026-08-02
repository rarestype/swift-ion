extension Ion.StructCursor {
    @frozen public struct Field: ~Copyable {
        public let id: Ion.Symbol
        @usableFromInline let value: Ion.NodeDecoder

        @inlinable init(
            id: Ion.Symbol,
            value: consuming Ion.NodeDecoder
        ) {
            self.id = id
            self.value = value
        }
    }
}
extension Ion.StructCursor.Field: Ion.FieldDecoder {
    @inlinable public func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        do {
            return try decode(self.value)
        } catch let error {
            throw Ion.DecodingError.init(any: error, in: .field(self.id))
        }
    }
}
