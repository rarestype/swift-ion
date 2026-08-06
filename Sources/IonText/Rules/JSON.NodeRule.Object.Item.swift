internal import Grammar

extension AST.NodeRule.Object {
    /// Matches an key-value expression.
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
        key: AST.SymbolKey,
        value: AST.Node
    ) where Source.Index == Location, Source.Element == Terminal {
        let key: String = try input.parse(as: AST.StringRule<Location>.self)
        try input.parse(as: AST.ColonRule<Location>.self)
        let value: AST.Node = try input.parse(as: AST.NodeRule<Location>.self)
        return (.text(key), value)
    }
}
