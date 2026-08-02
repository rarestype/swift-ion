extension Ion.Timestamp {
    @frozen public struct FractionalMinute {
        public let second: UInt8
        public var fraction: FractionalSecond?

        @inlinable init(second: UInt8, fraction: FractionalSecond? = nil) {
            self.second = second
            self.fraction = fraction
        }
    }
}
extension Ion.Timestamp.FractionalMinute {
    @inlinable public subscript(e exponent: Int) -> Ion.Timestamp.FractionalSecond {
        _read {
            yield  self.fraction[default: { .init(exponent: exponent) }]
        }
        _modify {
            yield &self.fraction[default: { .init(exponent: exponent) }]
        }
    }
}
