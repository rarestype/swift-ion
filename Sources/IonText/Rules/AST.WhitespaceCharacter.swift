internal import Grammar

extension AST {
    /// Matches a single whitespace character: U+0020, `\t`, `\n`, or `\r`.
    ///
    /// >   Note: Unicode space characters, like U+2009, are not
    ///     considered whitespace characters in the context of AST parsing.
    enum WhitespaceCharacter<Location> {}
}
extension AST.WhitespaceCharacter: TerminalRule {
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
