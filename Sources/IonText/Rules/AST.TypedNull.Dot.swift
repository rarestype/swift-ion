internal import Grammar

extension AST.TypedNull {
    enum Dot: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            terminal == 0x2E ? () : nil // '.'
        }
    }
}
