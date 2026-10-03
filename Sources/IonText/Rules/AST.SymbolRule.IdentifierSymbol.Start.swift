internal import Grammar

extension AST.SymbolRule.IdentifierSymbol {
    /// Matches a byte that is allowed to start an identifier symbol:
    /// `a`–`z`, `A`–`Z`, `_`, or `$`.
    enum Start: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            switch terminal {
            case 0x41 ... 0x5A: () // 'A'...'Z'
            case 0x61 ... 0x7A: () // 'a'...'z'
            case 0x5F: () // '_'
            case 0x24: () // '$'
            default: nil
            }
        }
    }
}
