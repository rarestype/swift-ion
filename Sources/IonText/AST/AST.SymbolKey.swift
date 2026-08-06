import Ion

extension AST {
    enum SymbolKey: Equatable, Hashable, Sendable {
        case text(String)
        case id(Ion.Symbol.ID)
    }
}
