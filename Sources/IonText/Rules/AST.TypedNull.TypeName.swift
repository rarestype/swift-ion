internal import Grammar

extension AST.TypedNull {
    /// Matches a byte allowed in a typed-null type name: `a`–`z`.
    enum TypeName: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            switch terminal {
            case 0x61 ... 0x7A: () // 'a'...'z'
            default: nil
            }
        }
    }
}
