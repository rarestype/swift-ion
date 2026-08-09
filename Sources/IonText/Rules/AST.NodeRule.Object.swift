internal import Grammar

extension AST.NodeRule {
    /// Matches an object literal.
    ///
    /// Object literals begin and end with curly braces (`{` and `}`), and
    /// contain instances of ``Item`` separated by ``AST.CommaRule``s.
    /// Trailing commas are not allowed.
    enum Object {}
}
extension AST.NodeRule.Object: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Struct
        where Source.Index == Location, Source.Element == Terminal {
        try input.parse(as: AST.BraceLeftRule<Location>.self)
        var items: [(key: AST.Symbol, value: AST.Node)]
        if  let head: (key: AST.Symbol, value: AST.Node) = try? input.parse(as: Item.self) {
            items = [head]
            while let (_, next): (Void, (key: AST.Symbol, value: AST.Node)) = try? input.parse(
                    as: (AST.CommaRule<Location>, Item).self
                ) {
                items.append(next)
            }
        } else {
            items = []
        }
        try input.parse(as: AST.BraceRightRule<Location>.self)
        return .init(fields: items)
    }
}
