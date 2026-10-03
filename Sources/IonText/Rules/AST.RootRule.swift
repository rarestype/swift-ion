internal import Grammar

extension AST {
    /// Matches a complete Ion text value, including leading and trailing
    /// whitespace and comments.
    enum RootRule<Location> {}
}
extension AST.RootRule: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = AST.Node

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Node
        where Source: Collection<Terminal>, Source.Index == Location {
        input.parse(as: AST.WhitespaceRule<Location>.self, in: Void.self)
        let node: AST.Node = try input.parse(as: AST.NodeRule<Location>.self)
        input.parse(as: AST.WhitespaceRule<Location>.self, in: Void.self)
        return node
    }
}
