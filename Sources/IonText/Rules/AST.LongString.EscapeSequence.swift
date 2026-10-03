internal import Grammar
import IonABI

extension AST.LongString {
    /// Matches a backslash-initiated escape sequence in a long string literal.
    ///
    /// The opening backslash must already be consumed by the caller.
    enum EscapeSequence: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = String

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> String
            where Source.Element == Terminal, Source.Index == Location {
            try parseEscape(&input)
        }

        static func parseEscape<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> String
            where Source.Element == Terminal, Source.Index == Location {
            typealias HexDigit = UnicodeDigit<Location, UInt8, UInt16>.Hex
            typealias ASCII = UnicodeEncoding<Location, UInt8>

            var unescaped: String = ""
            while true {
                if let scalar: Unicode.Scalar = input.parse(as: EscapedCodeUnit?.self) {
                    unescaped.append(Character.init(scalar))
                } else {
                    try input.parse(as: ASCII.LowercaseU.self)
                    let value: UInt16 =
                    (try input.parse(as: HexDigit.self) << 12) |
                    (try input.parse(as: HexDigit.self) <<  8) |
                    (try input.parse(as: HexDigit.self) <<  4) |
                    (try input.parse(as: HexDigit.self))
                    if let scalar: Unicode.Scalar = Unicode.Scalar.init(value) {
                        unescaped.append(Character.init(scalar))
                    } else {
                        throw .arbitrary(Ion.InvalidUnicodeScalarError.init(value: value))
                    }
                }
                guard case _? = input.parse(as: ASCII.Backslash?.self) else { break }
            }
            return unescaped
        }
    }
}
