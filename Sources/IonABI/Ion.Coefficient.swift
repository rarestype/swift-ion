extension Ion {
    @frozen public enum Coefficient {
        case int64(Sign, UInt64)
        case int128(Sign, UInt128)
        case arbitrary(Words)
    }
}
extension Ion.Coefficient: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral: Int64) {
        self = .int64(integerLiteral < 0 ? .negative : .positive, integerLiteral.magnitude)
    }
}
extension Ion.Coefficient {
    init(from input: inout Ion.Input) throws(Ion.InputError) {
        let size: Int = input.remaining
        if  size <= 0 {
            self = .int64(.positive, 0)
        } else if size <= 8 {
            let (negative, magnitude): (negative: Bool, UInt64) = try input.parse(octets: size)
            self = .int64(negative ? .negative : .positive, magnitude)
        } else if size <= 16 {
            let (negative, magnitude): (negative: Bool, UInt128) = try input.parse(octets: size)
            self = .int128(negative ? .negative : .positive, magnitude)
        } else {
            self = .arbitrary(try input.next(size) { .init(bytes: $0) })
        }
    }

    var bytesRequired: Int? {
        switch self {
        case .int64(.positive, 0):
            return nil
        case .int64(.negative, 0):
            return 1
        case .int64(_, let magnitude):
            return magnitude.bytesSpannedWithSign

        case .int128(.positive, 0):
            return nil
        case .int128(.negative, 0):
            return 1
        case .int128(_, let magnitude):
            return magnitude.bytesSpannedWithSign

        case .arbitrary(let words):
            return words.bytes.count
        }
    }

    static func += (output: inout Ion.Output, self: Self) {
        switch self {
        case .int64(.positive, 0):
            return
        case .int64(.negative, 0):
            output.write(
                fixed: (true, 0 as UInt8),
                octets: 1
            )
        case .int64(let sign, let magnitude):
            output.write(
                fixed: (sign == .negative, magnitude),
                octets: magnitude.bytesSpannedWithSign
            )

        case .int128(.positive, 0):
            return
        case .int128(.negative, 0):
            output.write(
                fixed: (true, 0 as UInt8),
                octets: 1
            )
        case .int128(let sign, let magnitude):
            output.write(
                fixed: (sign == .negative, magnitude),
                octets: magnitude.bytesSpannedWithSign
            )

        case .arbitrary(let words):
            output.append(words.bytes)
        }
    }
}
