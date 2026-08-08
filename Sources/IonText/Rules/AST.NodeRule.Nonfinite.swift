internal import Grammar
import IonABI

extension AST.NodeRule {
    enum Nonfinite: ParsingRule {
        typealias Terminal = UInt8

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> AST.Number
            where Source.Element == Terminal, Source.Index == Location {
            if  let _: Void = input.parse(
                    as: UnicodeEncoding<Location, UInt8>.LowercaseS?.self
                ) {
                try input.parse(as: AST.NodeRule<Location>.NaN.self)
                return .float(.float32(.signalingNaN))
            } else if
                let _: Void = input.parse(as: AST.NodeRule<Location>.NaN?.self) {
                return .float(.float32(.nan))
            }

            let sign: Ion.Sign? = input.parse(as: AST.NumberRule<Location>.PlusOrMinus?.self)
            try input.parse(as: Inf.self)
            if  case .negative? = sign {
                return .float(.float32(-.infinity))
            } else {
                return .float(.float32(+.infinity))
            }
        }
    }
}
