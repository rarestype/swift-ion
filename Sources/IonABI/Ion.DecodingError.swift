extension Ion {
    @frozen public struct DecodingError: Error {
        /// The underlying error that occurred.
        public let underlying: any Error
        /// The key path where the ``underlying`` error originated from. The first value is the
        /// location closest to where the error came from.
        @usableFromInline var stack: [Location]

        @inlinable init(underlying: any Error, stack: [Location]) {
            self.underlying = underlying
            self.stack = stack
        }
    }
}
extension Ion.DecodingError {
    @inlinable init(any error: consuming any Error, in location: Location) {
        switch consume error {
        case var trace as Self:
            trace.stack.append(location)
            self = trace
        case let error:
            self.init(underlying: error, stack: [location])
        }
    }
}
extension Ion.DecodingError: CustomStringConvertible {
    public var description: String {
        var path: String = "\\"
        for step: Location in self.stack.reversed() {
            switch step {
            case .index(let i):
                path += "[\(i)]"
            case .field(let id):
                path += ".\(id)"
            }
        }
        return "ion decoding error in \(path): \(self.underlying)"
    }
}
