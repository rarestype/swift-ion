internal import Grammar
import IonABI

extension AST {
    /// Matches a long string literal (`"""..."""`), including concatenation
    /// of adjacent long string fragments.
    enum LongString<Location> {}
}
extension AST.LongString {
    private static func parseFragment<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> String
        where Source.Element == Terminal, Source.Index == Location {
        try input.parse(as: TripleQuote.self)
        var result: String = ""
        while true {
            let start: Location = input.index
            input.parse(as: CodeUnit.self, in: Void.self)
            let end: Location = input.index
            if end > start {
                result += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            }
            if let _: Void = input.parse(as: TripleQuote?.self) {
                return result
            }
            if let _: Void = input.parse(as: LineContinuation?.self) {
                continue
            }
            if let escaped: String = input.parse(as: EscapeSequence?.self) {
                result += escaped
                continue
            }
            if let _: Void = input.parse(as: Newline?.self) {
                result += "\n"
                continue
            }
            if let _: Void = input.parse(
                as: UnicodeEncoding<Location, UInt8>.DoubleQuote?.self
            ) {
                result += "\""
                continue
            }
            throw .unexpectedValue
        }
    }
}
extension AST.LongString: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = String

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> String
        where Source.Element == Terminal, Source.Index == Location {
        var result: String = try Self.parseFragment(&input)
        while true {
            let saved: Location = input.index
            input.parse(as: AST.WhitespaceRule<Location>.self, in: Void.self)
            if let next: String = try? Self.parseFragment(&input) {
                result += next
            } else {
                input.index = saved
                break
            }
        }
        return result
    }
}
