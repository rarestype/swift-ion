extension AST {
    /// A string literal contained a unicode escape sequence that does not encode a
    /// valid ``Unicode/Scalar``.
    @frozen public struct InvalidUnicodeScalarError: Error, Equatable, Sendable {
        public let value: UInt16
        @inlinable public init(value: UInt16) {
            self.value = value
        }
    }
}
