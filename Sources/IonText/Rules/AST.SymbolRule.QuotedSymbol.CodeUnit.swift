internal import Grammar

extension AST.SymbolRule.QuotedSymbol {
    /// Matches a UTF-8 code unit that is allowed to appear inline in a quoted symbol literal.
    enum CodeUnit {}
}
extension AST.SymbolRule.QuotedSymbol.CodeUnit: TerminalRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse(terminal: UInt8) -> Void? {
        switch terminal {
        case 0x20 ... 0x26: ()
        case 0x28 ... 0x5B: ()
        case 0x5D ... 0xFF: ()
        default: nil
        }
    }
}
