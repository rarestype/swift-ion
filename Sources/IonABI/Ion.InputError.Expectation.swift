extension Ion.InputError {
    @frozen @usableFromInline enum Expectation: Sendable {
        /// The input should have yielded end-of-input.
        case end
        /// The input should have yielded a terminator byte that never appeared.
        case byte(UInt8)
        /// The input should have yielded a particular number of bytes.
        case bytes(Int)
        case value
        case header
        case inhabitant
    }
}
extension Ion.InputError.Expectation: CustomStringConvertible {
    @usableFromInline var description: String {
        switch self {
        case .end:
            "end-of-input"
        case .bytes(let count):
            "\(count) byte(s)"
        case .byte(let byte):
            "terminator byte (\(byte))"
        case .header:
            "type descriptor"
        case .value:
            "value"
        case .inhabitant:
            "inhabitant"
        }
    }
}
