internal import Grammar

extension AST.NodeRule {
    /// Matches an array literal.
    ///
    /// Array literals begin and end with square brackets (`[` and `]`), and
    /// recursively contain instances of ``AST.NodeRule`` separated by ``AST.CommaRule``s.
    enum Array {}
}
extension AST.NodeRule.Array: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> [AST.Node]
        where Source.Element == Terminal, Source.Index == Location {
        try input.parse(as: AST.BracketLeftRule<Location>.self)
        var elements: [AST.Node]
        if let head: AST.Node = try? input.parse(as: AST.NodeRule<Location>.self) {
            elements = [head]
            while let (_, next): (Void, AST.Node) = try? input.parse(
                    as: (AST.CommaRule<Location>, AST.NodeRule<Location>).self
                ) {
                elements.append(next)
            }
        } else {
            elements = []
        }
        try input.parse(as: AST.BracketRightRule<Location>.self)
        return elements
    }
}
