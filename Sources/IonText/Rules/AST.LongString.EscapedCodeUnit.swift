internal import Grammar

extension AST.LongString {
    /// Matches an ASCII character allowed after a backslash in a long string.
    enum EscapedCodeUnit {}
}
extension AST.LongString.EscapedCodeUnit: TerminalRule {
    typealias Terminal = UInt8
    typealias Construction = Unicode.Scalar

    static func parse(terminal: UInt8) -> Unicode.Scalar? {
        switch terminal {
        case 0x5C: .init(0x5C) // '\\'
        case 0x22: .init(0x22) // '\"'
        case 0x27: .init(0x27) // '\''
        case 0x2F: .init(0x2F) // '\/'
        case 0x62: .init(0x08) // '\b'
        case 0x66: .init(0x0C) // '\f'
        case 0x6E: .init(0x0A) // '\n'
        case 0x72: .init(0x0D) // '\r'
        case 0x74: .init(0x09) // '\t'
        default: nil
        }
    }
}
