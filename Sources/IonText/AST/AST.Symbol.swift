import IonABI

extension AST {
    enum Symbol: Equatable, Hashable, Sendable {
        case name(String)
        case preassigned(Ion.Symbol.ID)
    }
}
