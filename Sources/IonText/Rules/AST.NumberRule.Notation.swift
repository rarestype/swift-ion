internal import Grammar
import IonABI

extension AST.NumberRule {
    /// Matches an ASCII letter `b` or `x`.
    enum Notation: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Ion.IntegerNotation

        static func parse(terminal: UInt8) -> Ion.IntegerNotation? {
            switch terminal {
            case 0x62: .b // b
            case 0x42: .b // B
            case 0x78: .x // x
            case 0x58: .x // X
            default: nil
            }
        }
    }
}
