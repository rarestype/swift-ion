extension Ion {
    @frozen public enum Coefficient {
        case int64(Int64)
        case int128(Int128)
        case arbitrary(Words)
    }
}
extension Ion.Coefficient {
    init(from input: inout Ion.Input) throws(Ion.InputError) {
        let size: Int = input.remaining
        if  size <= 0 {
            self = .int64(0)
        } else if size <= 8 {
            let (negative, magnitude): (negative: Bool, UInt64) = try input.parse(octets: size)
            self = .int64(Int64.init(bitPattern: negative ? 0 &- magnitude : magnitude))
        } else if size <= 16 {
            let (negative, magnitude): (negative: Bool, UInt128) = try input.parse(octets: size)
            self = .int128(Int128.init(bitPattern: negative ? 0 &- magnitude : magnitude))
        } else {
            self = .arbitrary(try input.next(size) { .init(bytes: $0) })
        }
    }

    var bytesRequired: Int? {
        switch self {
        case .int64(0):
            return nil
        case .int64(let self):
            return self.magnitude.bytesSpannedWithSign

        case .int128(0):
            return nil
        case .int128(let self):
            return self.magnitude.bytesSpannedWithSign

        case .arbitrary(let words):
            return words.bytes.count
        }
    }

    static func += (output: inout Ion.Output, self: Self) {
        switch self {
        case .int64(0):
            return
        case .int64(let self):
            let magnitude: UInt64 = self.magnitude
            output.write(
                fixed: (negative: self < 0, magnitude),
                octets: magnitude.bytesSpannedWithSign
            )

        case .int128(0):
            return
        case .int128(let self):
            let magnitude: UInt128 = self.magnitude
            output.write(
                fixed: (negative: self < 0, magnitude),
                octets: magnitude.bytesSpannedWithSign
            )

        case .arbitrary(let words):
            output.append(words.bytes)
        }
    }
}
