extension Ion.Timestamp {
    @frozen public struct FractionalDay {
        public let hour: UInt8
        public let minute: UInt8
        public var fraction: FractionalMinute?

        @inlinable init(hour: UInt8, minute: UInt8, fraction: FractionalMinute? = nil) {
            self.hour = hour
            self.minute = minute
            self.fraction = fraction
        }
    }
}
extension Ion.Timestamp.FractionalDay {
    @inlinable public var time: (hour: UInt8, minute: UInt8, second: UInt8) {
        (self.hour, self.minute, self.fraction?.second ?? 0)
    }
}
extension Ion.Timestamp.FractionalDay {
    @inlinable public subscript(second: UInt8) -> Ion.Timestamp.FractionalMinute {
        _read {
            yield  self.fraction[default: { .init(second: second) }]
        }
        _modify {
            yield &self.fraction[default: { .init(second: second) }]
        }
    }
}
