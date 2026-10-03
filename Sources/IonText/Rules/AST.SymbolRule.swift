internal import Grammar
import IonABI

extension AST {
    /// Matches an Ion symbol: either an identifier symbol (bare word) or a
    /// quoted symbol literal (single-quoted string).
    enum SymbolRule<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = AST.Symbol

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> AST.Symbol
            where Source.Element == Terminal, Source.Index == Location {
            if let symbol: Ion.Symbol = input.parse(as: IdentifierSymbol?.self) {
                return .name(symbol)
            }
            let symbol: Ion.Symbol = try input.parse(as: QuotedSymbol.self)
            return .name(symbol)
        }
    }
}
