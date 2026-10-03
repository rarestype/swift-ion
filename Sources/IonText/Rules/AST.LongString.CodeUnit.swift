internal import Grammar

extension AST.LongString {
    /// Matches a UTF-8 code unit allowed inline in a long string literal.
    ///
    /// Excludes `"` (0x22), `\` (0x5C), and control characters (0x00–0x1F).
    /// The closing `"""` check and lone-`"` handling are performed in the
    /// parse loop.
    enum CodeUnit: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            switch terminal {
            case 0x20 ... 0x21: ()
            case 0x23 ... 0x5B: ()
            case 0x5D ... 0xFF: ()
            default: nil
            }
        }
    }
}
