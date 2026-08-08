internal import Grammar
import IonABI

extension AST {
    /// Matches a numeric literal.
    enum NumberRule<Location> {}
}
extension AST.NumberRule: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Number
        where Source.Element == Terminal, Source.Index == Location {
        /// ASCII decimal digit terminals.
        typealias DecimalDigit<T> = UnicodeDigit<Location, UInt8, T>.Decimal where T: BinaryInteger
        /// ASCII terminals.
        typealias ASCII = UnicodeEncoding<Location, UInt8>

        let start: Source.Index = input.index
        let sign: Ion.Sign? = input.parse(as: PlusOrMinus?.self)

        /// parse integral component
        let first: UInt64 = try input.parse(as: DecimalDigit<UInt64>.self)
        let radix: Ion.IntegerNotation? = input.parse(as: Notation?.self)
        var units: Ion.IntegerAccumulator = .uint64(first)
        switch radix {
        case .b?:
            repeat {} while units.parse(
                digit: UnicodeDigit<Location, UInt8, UInt64>.Binary.self,
                input: &input
            )
        case nil:
            repeat {} while units.parse(
                digit: UnicodeDigit<Location, UInt8, UInt64>.Decimal.self,
                input: &input
            )
        case .x?:
            repeat {} while units.parse(
                digit: UnicodeDigit<Location, UInt8, UInt64>.Hex.self,
                input: &input
            )
        }

        var places: UInt32 = 0
        var period: Bool = false
        if  case nil = radix {
            /// parse fractional component, if present
            if  case ()? = input.parse(as: ASCII.Period?.self) {
                period = true
                // unlike json, ion allows the decimal point to have no trailing digits
                while let remainder: UInt64 = input.parse(as: DecimalDigit<UInt64>?.self) {
                    places += 1
                    units.shift(adding: remainder)
                }
            }

            switch input.parse(as: Exponent?.self) {
            case .e?:
                // to parse floats, we take the sanitized string representation and parse with
                // the standard library API
                let _: Ion.Sign? = input.parse(as: PlusOrMinus?.self)
                while case _? = input.parse(as: DecimalDigit<UInt64>?.self) {}

                let bytes: Int = input.source.distance(from: start, to: input.index)
                let value: String = .init(unsafeUninitializedCapacity: bytes) {
                    var i: Int = $0.startIndex
                    // filter out underscores
                    for utf8: UInt8 in input[start ..< input.index] where utf8 != 0x5f {
                        $0[i] = utf8
                        i = $0.index(after: i)
                    }
                    return $0.distance(from: $0.startIndex, to: i)
                }

                guard let value: Double = .init(value) else {
                    return .unrepresentable(value)
                }
                if  let value: Float = .init(exactly: value) {
                    return .float(.float32(value))
                } else {
                    return .float(.float64(value))
                }

            case .d?:
                period = true

                let exponent: (sign: Ion.Sign, magnitude: UInt32)

                exponent.sign = input.parse(as: PlusOrMinus?.self) ?? .positive
                exponent.magnitude = try input.parse(
                    as: Pattern.UnsignedInteger<DecimalDigit<UInt32>>.self
                )

                if  exponent.magnitude == 0 {
                    break
                }

                switch exponent.sign {
                case .negative:
                    // note: potential crash if `exponent.magnitude` is absurdly large
                    places += exponent.magnitude

                case .positive:
                    guard places < exponent.magnitude else {
                        // note: see above
                        places -= exponent.magnitude
                        break
                    }

                    let shift: Int
                    if  case .uint64(0) = units {
                        places = 0
                        break
                    } else {
                        shift = Int.init(exponent.magnitude - places)
                        places = 0
                    }

                    if  shift < AST.Number.Exp10.endIndex {
                        units.multiply(by: AST.Number.Exp10[shift])
                    } else {
                        units = .unrepresentable
                    }
                }

            case nil:
                break
            }
        }

        representable:
        if  period {
            let coefficient: Ion.Coefficient

            switch units {
            case .uint64(let units):
                if  case .negative? = sign {
                    if  units <= UInt64.init(bitPattern: Int64.min) {
                        coefficient = .int64(Int64.init(bitPattern: 0 &- units))
                    } else {
                        coefficient = .int128(Int128.init(units))
                    }
                } else {
                    if  let units: Int64 = .init(exactly: units) {
                        coefficient = .int64(units)
                    } else {
                        coefficient = .int128(Int128.init(units))
                    }
                }
            case .uint128(let units):
                if  case .negative? = sign {
                    if  units <= UInt128.init(bitPattern: Int128.min) {
                        coefficient = .int128(Int128.init(bitPattern: 0 &- units))
                    } else {
                        break representable
                    }
                } else {
                    if  let units: Int128 = .init(exactly: units) {
                        coefficient = .int128(units)
                    } else {
                        break representable
                    }
                }
            case .unrepresentable:
                break representable
            }

            return .decimal(.init(coefficient, e: -Int.init(places)))
        } else {
            switch units {
            case .uint64(let units):
                return .int(sign ?? .positive, .uint64(units))
            case .uint128(let units):
                return .int(sign ?? .positive, .uint128(units))
            case .unrepresentable:
                break representable
            }
        }

        /// number is not representable in efficient format, fall back to string
        return .unrepresentable(
            String.init(decoding: input[start ..< input.index], as: Unicode.UTF8.self)
        )
    }
}
