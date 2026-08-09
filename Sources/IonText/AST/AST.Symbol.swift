import IonABI

extension AST {
    enum Symbol: Equatable, Hashable, Sendable {
        case name(Ion.Symbol)
        case preassigned(Ion.Symbol.ID)
    }
}
extension AST.Symbol: CustomStringConvertible {
    var description: String {
        switch self {
        case .name(let symbol): "\(symbol)"
        case .preassigned(let id): "\(id)"
        }
    }
}
extension AST.Symbol: IonSymbolizable {
    func get(in symbol: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID? {
        switch self {
        case .name(let self): symbol[self]
        case .preassigned(let self): self
        }
    }
    func set(in symbol: inout Ion.SymbolEncoder) -> Ion.Symbol.ID {
        switch self {
        case .name(let self): symbol[self]
        case .preassigned(let self): self
        }
    }
}
