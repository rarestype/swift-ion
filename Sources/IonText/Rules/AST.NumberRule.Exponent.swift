internal import Grammar
import IonABI

extension AST.NumberRule {
    /// Matches an ASCII letter `e` or `d`.
    enum Exponent: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Ion.ExponentType

        static func parse(terminal: UInt8) -> Ion.ExponentType? {
            switch terminal {
            case 0x64: .d // d
            case 0x44: .d // D
            case 0x65: .e // e
            case 0x45: .e // E
            default: nil
            }
        }
    }
}
