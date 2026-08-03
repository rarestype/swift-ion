extension Ion.Timestamp {
    @frozen public struct FractionalYear {
        public let month: UInt8
        public var fraction: FractionalMonth?

        @inlinable init(month: UInt8, fraction: FractionalMonth? = nil) {
            self.month = month
            self.fraction = fraction
        }
    }
}
extension Ion.Timestamp.FractionalYear {
    @inlinable public subscript(day: UInt8) -> Ion.Timestamp.FractionalMonth {
        _read {
            yield  self.fraction[default: { .init(day: day) }]
        }
        _modify {
            yield &self.fraction[default: { .init(day: day) }]
        }
    }
}
