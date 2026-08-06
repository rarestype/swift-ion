internal import Grammar

extension AST {
    /// Matches the whitespace characters U+0020, `\t`, `\n`, and `\r`.
    ///
    /// This rule matches a *single* whitespace character.
    /// To match a sequence of whitespace characters (including the empty sequence),
    /// use one of `swift-grammar`’s vector parsing APIs, like ``ParsingInput.parse(as:in:)``.
    ///
    /// For example, the following is equivalent to the regex `/[\ \t\n\r]+/`:
    /**
    ```swift
    try input.parse(as: AST.WhitespaceRule<Location>.self)
        input.parse(as: AST.WhitespaceRule<Location>.self, in: Void.self)
    ```
    */
    /// >   Note: Unicode space characters, like U+2009, are not
    ///     considered whitespace characters in the context of AST parsing.
    enum WhitespaceRule<Location>: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            switch terminal {
            case 0x20: () // ' '
            case 0x09: () // '\t'
            case 0x0a: () // '\n'
            case 0x0d: () // '\r'
            default: nil
            }
        }
    }
}
