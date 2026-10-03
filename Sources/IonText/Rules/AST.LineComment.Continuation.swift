internal import Grammar

extension AST.LineComment {
    /// Matches any UTF-8 code unit except U+000A (newline).
    enum Continuation {}
}
extension AST.LineComment.Continuation: TerminalRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse(terminal: UInt8) -> Void? {
        if terminal == 0x0A { return nil }
        return ()
    }
}
