extension Ion {
    @frozen @usableFromInline enum MessageFormatError: Error {
        case expectedIVM
        case expectedBody
    }
}
extension Ion.MessageFormatError: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .expectedIVM:
            "atomic ion message must begin with the Ion Version Marker (IVM)"
        case .expectedBody:
            "atomic ion message must include a payload"
        }
    }
}
