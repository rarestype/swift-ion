internal import Grammar
import IonABI

extension AST.NodeRule.Object {
    /// Matches a key-value expression.
    ///
    /// A key-value expression consists of a ``AST.StringRule``, a ``AST.ColonRule``, and
    /// a recursive instance of ``AST.NodeRule``.
    enum Item {}
}
extension AST.NodeRule.Object.Item: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> (
        key: AST.Symbol,
        value: AST.Node
    ) where Source.Index == Location, Source.Element == Terminal {
        let key: AST.Symbol
        if let string: String = input.parse(as: AST.StringRule<Location>?.self) {
            key = .name(Ion.Symbol.init(string))
        } else {
            key = try input.parse(as: AST.SymbolRule<Location>.self)
        }
        try input.parse(as: AST.ColonRule<Location>.self)
        let value: AST.Node = try input.parse(as: AST.NodeRule<Location>.self)
        return (key, value)
    }
}
