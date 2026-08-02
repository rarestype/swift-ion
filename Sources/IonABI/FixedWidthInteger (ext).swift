extension FixedWidthInteger where Self: SignedInteger {
    @inlinable public init?(exactly coefficient: borrowing Ion.Coefficient) {
        switch coefficient {
        case .int64(let value):
            guard let value: Self = .init(exactly: value) else {
                return nil
            }
            self = value
        case .int128(let value):
            guard let value: Self = .init(exactly: value) else {
                return nil
            }
            self = value
        case .arbitrary(let words):
            let value: (negative: Bool, magnitude: Magnitude) = words.load()
            self.init(exactly: value)
        }
    }
}
extension FixedWidthInteger {
    @inlinable public init?(exactly: __shared (Ion.Sign, Ion.Magnitude)) {
        switch exactly {
        case (.positive, let magnitude):
            self.init(exactly: magnitude)

        case (.negative, let magnitude):
            // A signed integer `T` can hold negative values up to the magnitude of `T.min`.
            guard
            let magnitude: Magnitude = .init(exactly: magnitude),
                magnitude <= Self.min.magnitude else {
                return nil
            }

            // for unsigned integers, this is effectively unreachable, as negative zero is
            // forbidden at the parser level
            self.init(truncatingIfNeeded: 0 &- magnitude)
        }
    }

    @inlinable init?(exactly magnitude: borrowing Ion.Magnitude) {
        switch magnitude {
        case .uint64(let magnitude):
            self.init(exactly: magnitude)
        case .uint128(let magnitude):
            self.init(exactly: magnitude)
        case .arbitrary(let words):
            let trimmed: ArraySlice<UInt8> = words.bytes.drop { $0 == 0 }
            if  trimmed.count > MemoryLayout<Self.Magnitude>.size {
                return nil
            }

            self.init(exactly: words.load(into: Self.Magnitude.self))
        }
    }
}
extension FixedWidthInteger where Self: SignedInteger {
    @inlinable init?(exactly: (negative: Bool, magnitude: Magnitude)) {
        switch exactly {
        case (negative: true, magnitude: let magnitude):
            if  Self.min.magnitude < magnitude {
                return nil
            }
            self.init(truncatingIfNeeded: 0 &- magnitude)

        case (negative: false, magnitude: let magnitude):
            self.init(exactly: magnitude)
        }
    }
}
extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(always) @inlinable subscript(byte j: Int) -> UInt8 {
        let bits: UInt8 = .init(truncatingIfNeeded: self >> (j * 7))
        let byte: UInt8
        if  j == 0 {
            byte = bits | 0b1000_0000
        } else {
            byte = bits & 0b0111_1111
        }
        return byte
    }

    @inline(always) @inlinable subscript(byte j: Int, sign sign: Bool) -> UInt8 {
        let bits: UInt8 = .init(truncatingIfNeeded: self >> (j * 7))
        let byte: UInt8
        if  j == 0 {
            byte = bits | 0b1000_0000
        } else {
            byte = bits & 0b0111_1111
        }

        if  sign {
            return byte | 0b0100_0000
        } else {
            return byte
        }
    }

    /// Returns the minimum number of bytes needed to encode this unsigned integer value as a
    /// variable-width Ion integer.
    @inlinable var bytesRequired: Int {
        if  self == 0 {
            return 1
        }
        let w: Int = Self.bitWidth - self.leadingZeroBitCount
        return (w + 6) / 7
    }
    /// Returns the minimum number of bytes needed to encode this signed integer value as a
    /// variable-width Ion integer.
    @inlinable var bytesRequiredWithSign: Int {
        // 1st byte holds 6 bits, others hold 7, equation is `(w + 1 + 6) / 7`
        let w: Int = Self.bitWidth - self.leadingZeroBitCount
        return w / 7 + 1
    }

    /// Returns the minimum number of bytes needed to encode this unsigned integer value as a
    /// length-prefixed Ion integer.
    @inlinable var bytesSpanned: Int {
        let w: Int = Self.bitWidth - self.leadingZeroBitCount
        return (w + 7) / 8
    }
    /// Returns the minimum number of bytes needed to encode this signed integer value as a
    /// length-prefixed Ion integer.
    @inlinable var bytesSpannedWithSign: Int {
        // 1st byte holds 7 bits, others hold 8, equation is `(w + 1 + 7) / 8`
        let w: Int = Self.bitWidth - self.leadingZeroBitCount
        return w / 8 + 1
    }
}
