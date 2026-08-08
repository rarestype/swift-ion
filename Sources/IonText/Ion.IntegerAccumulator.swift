internal import Grammar
import IonABI

extension Ion {
    enum IntegerAccumulator {
        case uint64(UInt64)
        case uint128(UInt128)
        case unrepresentable
    }
}
extension Ion.IntegerAccumulator {
    mutating func parse<Digit, Source>(
        digit: Digit.Type,
        input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) -> Bool where Digit: DigitRule<UInt8, UInt64>,
        Source.Element == UInt8,
        Source.Index == Digit.Location {
        if  let (_, remainder): (()?, UInt64) = try? input.parse(
                as: (UnicodeEncoding<Digit.Location, UInt8>.Underscore?, Digit).self
            ) {
            self.shift(adding: remainder, radix: Digit.radix)
            return true
        } else {
            return false
        }
    }

    mutating func shift(adding remainder: UInt64, radix: UInt64 = 10) {
        switch self {
        case .uint64(let units):
            if  case (let shifted, false) = units.multipliedReportingOverflow(by: radix),
                case (let refined, false) = shifted.addingReportingOverflow(remainder) {
                self = .uint64(refined)
            } else {
                let radix: UInt128 = .init(radix)
                self = .uint128(UInt128.init(units) * radix + UInt128.init(remainder))
            }

        case .uint128(let units):
            let radix: UInt128 = .init(radix)
            if  case (let shifted, false) = units.multipliedReportingOverflow(by: radix),
                case (let refined, false) = shifted.addingReportingOverflow(
                    UInt128.init(remainder)
                ) {
                self = .uint128(refined)
            } else {
                self = .unrepresentable
            }

        case .unrepresentable:
            return
        }
    }

    mutating func multiply(by factor: UInt64) {
        switch self {
        case .uint64(let units):
            if  case (let product, false) = units.multipliedReportingOverflow(by: factor) {
                self = .uint64(product)
                return
            }

            let factor: UInt128 = .init(factor)
            let units: UInt128 = .init(units)

            if  case (let product, false) = units.multipliedReportingOverflow(by: factor) {
                self = .uint128(product)
            } else {
                self = .unrepresentable
            }

        case .uint128(let units):
            let factor: UInt128 = .init(factor)
            if  case (let product, false) = units.multipliedReportingOverflow(by: factor) {
                self = .uint128(product)
            } else {
                self = .unrepresentable
            }

        case .unrepresentable:
            return
        }
    }
}
