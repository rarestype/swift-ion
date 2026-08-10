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
            let (sign, magnitude): (Ion.Sign, UInt64) = try input.parse(octets: size)
            self = .int64(sign, magnitude)
        } else if size <= 16 {
            let (sign, magnitude): (Ion.Sign, UInt128) = try input.parse(octets: size)
            self = .int128(sign, magnitude)
        } else {
            self = .arbitrary(try input.next(size) { .init(bytes: $0) })
        }
    }

    var bytesRequired: Int? {
        switch self {
        case .int64(.positive, 0):
            return nil
        case .int64(_, let magnitude):
            return magnitude.bytesSpannedWithSign

        case .int128(.positive, 0):
            return nil
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
        case .int64(let sign, let magnitude):
            output.write(fixed: (sign, magnitude), octets: magnitude.bytesSpannedWithSign)

        case .int128(.positive, 0):
            return
        case .int128(let sign, let magnitude):
            output.write(fixed: (sign, magnitude), octets: magnitude.bytesSpannedWithSign)

        case .arbitrary(let words):
            output.append(words.bytes)
        }
    }
}
