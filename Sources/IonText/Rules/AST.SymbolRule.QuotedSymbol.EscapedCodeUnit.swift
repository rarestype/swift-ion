internal import Grammar

extension AST.SymbolRule.QuotedSymbol {
    /// Matches an ASCII character that is allowed to appear immediately after
    /// a backslash (`\`) in a quoted symbol literal.
    ///
    /// The following are valid escape characters: `\`, `'`, `/`, `b`, `f`, `n`, `r`, `t`.
    enum EscapedCodeUnit: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Unicode.Scalar

        static func parse(terminal: UInt8) -> Unicode.Scalar? {
            switch terminal {
            case 0x5C, 0x27, 0x2F: .init(terminal) // '\\', '\'', '\/'
            case 0x62: "\u{08}" // '\b'
            case 0x66: "\u{0C}" // '\f'
            case 0x6E: "\u{0A}" // '\n'
            case 0x72: "\u{0D}" // '\r'
            case 0x74: "\u{09}" // '\t'
            default: nil
            }
        }
    }
}
