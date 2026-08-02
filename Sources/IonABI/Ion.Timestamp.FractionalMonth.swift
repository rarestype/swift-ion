extension Ion.Timestamp {
    @frozen public struct FractionalMonth {
        public let day: UInt8
        public var fraction: FractionalDay?

        @inlinable init(day: UInt8, fraction: FractionalDay? = nil) {
            self.day = day
            self.fraction = fraction
        }
    }
}
extension Ion.Timestamp.FractionalMonth {
    @inlinable public subscript(hour: UInt8, minute: UInt8) -> Ion.Timestamp.FractionalDay {
        _read {
           yield  self.fraction[default: { .init(hour: hour, minute: minute) }]
        }
        _modify {
           yield &self.fraction[default: { .init(hour: hour, minute: minute) }]
        }
    }
}
