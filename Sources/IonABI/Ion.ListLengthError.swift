extension Ion {
    /// A list decoded as a value with a fixed number of elements, such as a `SIMD3`, had more
    /// elements than that. A list with fewer elements fails to decode the first one it lacks.
    @frozen public struct ListLengthError: Equatable, Error {
        /// The number of elements the value has.
        public let expected: Int

        @inlinable public init(expected: Int) {
            self.expected = expected
        }
    }
}
extension Ion.ListLengthError: CustomStringConvertible {
    public var description: String {
        "list has more than the \(self.expected) elements expected"
    }
}
