internal import Grammar
import IonABI

extension AST.SymbolRule {
    /// Matches a quoted symbol literal: a single-quoted string with escape sequences.
    enum QuotedSymbol: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = Ion.Symbol

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> Ion.Symbol
            where Source.Element == Terminal, Source.Index == Location {
            typealias SingleQuote = UnicodeEncoding<Location, UInt8>.SingleQuote

            try input.parse(as: SingleQuote.self)

            let start: Location = input.index
            input.parse(as: CodeUnit.self, in: Void.self)
            let end: Location = input.index
            var text: String = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)

            while let escaped: String = input.parse(as: EscapeSequence?.self) {
                text += escaped
                let start: Location = input.index
                input.parse(as: CodeUnit.self, in: Void.self)
                let end: Location = input.index
                text += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            }

            try input.parse(as: SingleQuote.self)
            return Ion.Symbol.init(text)
        }
    }
}
