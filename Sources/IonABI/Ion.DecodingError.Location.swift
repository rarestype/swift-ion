extension Ion.DecodingError {
    /// The location (key or index) where the error occurred.
    @frozen public enum Location {
        case field(String)
        case index(Int)
    }
}
extension Ion.DecodingError.Location {
    @inlinable static func field(_ symbol: some CustomStringConvertible) -> Self {
        .field("\(symbol)")
    }
}
