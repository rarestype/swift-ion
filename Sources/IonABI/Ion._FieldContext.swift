extension Ion {
    @frozen @usableFromInline struct _FieldContext<ID, Failure>: ~Copyable
        where ID: CustomStringConvertible, Failure: Error {
        @usableFromInline let id: ID
        @usableFromInline let value: Result<Ion.NodeDecoder, Failure>

        @inlinable init(
            id: ID,
            value: consuming Result<Ion.NodeDecoder, Failure>
        ) {
            self.id = id
            self.value = value
        }
    }
}
extension Ion._FieldContext {
    @inlinable func decode<T>(
        with decode: (borrowing Ion.NodeDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        switch self.value {
        case .success(let decoder):
            do {
                return try decode(decoder)
            } catch let error {
                throw Ion.DecodingError.init(any: error, in: .field(self.id))
            }
        case .failure(let error):
            throw error
        }
    }
}
