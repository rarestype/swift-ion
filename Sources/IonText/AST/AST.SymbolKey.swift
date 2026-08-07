import IonABI

extension AST {
    enum SymbolKey: Equatable, Hashable, Sendable {
        case text(String)
        case id(Ion.Symbol.ID)
    }
}
