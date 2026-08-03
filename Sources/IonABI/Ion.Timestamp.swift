extension Ion {
    @frozen public struct Timestamp {
        public let offset: Int16?
        public let year: UInt16
        @usableFromInline var fraction: FractionalYear?

        @inlinable public init(offset: Int16?, year: UInt16, fraction: FractionalYear? = nil) {
            self.offset = offset
            self.year = year
            self.fraction = fraction
        }
    }
}
extension Ion.Timestamp {
    @inlinable public init<E>(
        offset: Int16?,
        year: UInt16,
        with configure: borrowing (inout Self) throws(E) -> ()
    ) throws(E) {
        self.init(offset: offset, year: year)
        try configure(&self)
    }
}
extension Ion.Timestamp {
    static func parse(from input: inout Ion.Input) throws(Ion.InputError) -> Self {
        let offset: Int16?
        let parsed: (negative: Bool, magnitude: UInt16) = try input.parse(variable: Int16.self)
        if  parsed == (negative: true, 0) {
            offset = nil
        } else {
            guard
            let value: Int16 = .init(exactly: parsed) else {
                throw .expected(.inhabitant, remaining: input.remaining)
            }
            offset = value
        }

        let year: UInt16 = try input.parse()
        return try .init(offset: offset, year: year, from: &input)
    }

    private init(
        offset: Int16?,
        year: UInt16,
        from input: inout Ion.Input,
    ) throws(Ion.InputError) {
        self.init(offset: offset, year: year)

        if  input.exhausted {
            return
        }

        let month: UInt8 = try input.parse()

        if  input.exhausted {
            self[month].fraction = nil
            return
        }

        let day: UInt8 = try input.parse()

        if  input.exhausted {
            self[month][day].fraction = nil
            return
        }

        let h: UInt8 = try input.parse()
        let m: UInt8 = try input.parse()

        if  input.exhausted {
            self[month][day][h, m].fraction = nil
            return
        }

        let s: UInt8 = try input.parse()

        if  input.exhausted {
            self[month][day][h, m][s].fraction = nil
            return
        }

        let e: Int = try input.parse()

        if  input.exhausted {
            self[month][day][h, m][s][e: e].coefficient = nil
        } else {
            self[month][day][h, m][s][e: e].coefficient = try Ion.Coefficient.init(from: &input)
        }
    }
}
extension Ion.Timestamp {
    private var bytesRequired: Int {
        var size: Int = self.year.bytesRequired

        if  let offset: Int16 = self.offset {
            size += offset.magnitude.bytesRequiredWithSign
        } else {
            size += 1
        }

        guard
        let fraction: Ion.Timestamp.FractionalYear = self.fraction else {
            return size
        }

        size += fraction.month.bytesRequired

        guard
        let fraction: Ion.Timestamp.FractionalMonth = fraction.fraction else {
            return size
        }

        size += fraction.day.bytesRequired

        guard
        let fraction: Ion.Timestamp.FractionalDay = fraction.fraction else {
            return size
        }

        size += fraction.hour.bytesRequired
        size += fraction.minute.bytesRequired

        guard
        let fraction: Ion.Timestamp.FractionalMinute = fraction.fraction else {
            return size
        }

        size += fraction.second.bytesRequired

        guard
        let fraction: Ion.Timestamp.FractionalSecond = fraction.fraction else {
            return size
        }

        size += fraction.exponent.magnitude.bytesRequiredWithSign

        guard
        let coefficient: Int = fraction.coefficient?.bytesRequired else {
            return size
        }

        size += coefficient
        return size
    }

    @usableFromInline static func += (output: inout Ion.Output, self: Self) {
        let size: Int = self.bytesRequired

        output[type: .timestamp, size: size]
        output.reserve(another: size)

        if  let offset: Int16 = self.offset {
            output.write(variable: offset, allocate: false)
        } else {
            output.append(0xC0)
        }

        output.write(variable: self.year, allocate: false)

        guard
        let fraction: Ion.Timestamp.FractionalYear = self.fraction else {
            return
        }

        output.write(variable: fraction.month, allocate: false)

        guard
        let fraction: Ion.Timestamp.FractionalMonth = fraction.fraction else {
            return
        }

        output.write(variable: fraction.day, allocate: false)

        guard
        let fraction: Ion.Timestamp.FractionalDay = fraction.fraction else {
            return
        }

        output.write(variable: fraction.hour, allocate: false)
        output.write(variable: fraction.minute, allocate: false)

        guard
        let fraction: Ion.Timestamp.FractionalMinute = fraction.fraction else {
            return
        }

        output.write(variable: fraction.second, allocate: false)

        guard
        let fraction: Ion.Timestamp.FractionalSecond = fraction.fraction else {
            return
        }

        output.write(variable: fraction.exponent, allocate: false)

        guard
        let coefficient: Ion.Coefficient = fraction.coefficient else {
            return
        }

        output += coefficient
    }
}
extension Ion.Timestamp {
    @inlinable public subscript(month: UInt8) -> FractionalYear {
        _read {
            yield  self.fraction[default: { .init(month: month) }]
        }
        _modify {
            yield &self.fraction[default: { .init(month: month) }]
        }
    }
}
extension Ion.Timestamp {
    public typealias NullGroup = Self
}
extension Ion.Timestamp: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) { ion.output += self }
}
extension Ion.Timestamp: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.timestamp)
    }
}
extension Ion.Timestamp: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .timestamp }
}
