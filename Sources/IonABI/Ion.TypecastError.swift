extension Ion {
    /// A decoder failed to cast a variant to an expected value type.
    @frozen public struct TypecastError<Value>: Equatable, Error {
        public let variant: AnyType

        @inlinable public init(invalid variant: AnyType) {
            self.variant = variant
        }
    }
}
extension Ion.TypecastError: CustomStringConvertible {
    public var description: String {
        "cannot cast variant of type '\(self.variant)' to type '\(Value.self)'"
    }
}
