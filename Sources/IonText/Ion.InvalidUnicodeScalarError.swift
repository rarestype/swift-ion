import IonABI

extension Ion {
    /// A string literal contained a unicode escape sequence that does not encode a
    /// valid ``Unicode/Scalar``.
    struct InvalidUnicodeScalarError: Error, Equatable, Sendable {
        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }
    }
}
extension Ion.InvalidUnicodeScalarError: CustomStringConvertible {
    var description: String {
        "invalid unicode scalar 'U+\(String.init(value, radix: 16))'"
    }
}
