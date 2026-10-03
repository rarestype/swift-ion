internal import Grammar

extension AST {
    /// Matches a single whitespace character, a line comment, or a block comment.
    ///
    /// To match a sequence of whitespace and comments (including the empty sequence),
    /// use one of `gram`’s vector parsing APIs, like ``ParsingInput.parse(as:in:)``.
    enum WhitespaceRule<Location> {}
}
extension AST.WhitespaceRule: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> Void
        where Source.Element == Terminal, Source.Index == Location {
        if let _: Void = input.parse(as: AST.WhitespaceCharacter<Location>?.self) {
            return
        }
        if let _: Void = input.parse(as: AST.LineComment<Location>?.self) {
            return
        }
        try input.parse(as: AST.BlockComment<Location>.self)
    }
}
