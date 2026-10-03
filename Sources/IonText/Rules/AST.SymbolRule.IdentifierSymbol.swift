internal import Grammar
import IonABI

extension AST.SymbolRule {
    /// Matches an identifier symbol: a bare word that is not a reserved keyword.
    ///
    /// Identifier symbols begin with a letter, underscore, or dollar sign,
    /// and continue with any of those characters or a digit.
    enum IdentifierSymbol: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = Ion.Symbol

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> Ion.Symbol
            where Source.Element == Terminal, Source.Index == Location {
            let start: Location = input.index
            try input.parse(as: Start.self)
            input.parse(as: Continue.self, in: Void.self)
            let end: Location = input.index
            let text: String = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            switch text {
            case "null", "true", "false", "nan", "inf":
                throw .unexpectedValue
            default:
                return Ion.Symbol.init(text)
            }
        }
    }
}
