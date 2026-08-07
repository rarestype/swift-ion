internal import Grammar
import IonABI

extension AST.NumberRule {
    /// Matches an ASCII `+` or `-` sign.
    enum PlusOrMinus: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Ion.Sign

        static func parse(terminal: UInt8) -> Ion.Sign? {
            switch terminal {
            case 0x2b: .positive
            case 0x2d: .negative
            default: nil
            }
        }
    }
}
