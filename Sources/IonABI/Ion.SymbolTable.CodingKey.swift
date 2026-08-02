internal import Bijection

extension Ion.SymbolTable {
    @frozen @usableFromInline enum CodingKey {
        case imports
        case symbols
    }
}
extension Ion.SymbolTable.CodingKey: Identifiable {
    @Bijection(label: "id") @inlinable var id: Ion.Symbol.ID {
        switch self {
        case .imports: .imports
        case .symbols: .symbols
        }
    }
}
extension Ion.SymbolTable.CodingKey: IonSymbolizable {
    @inlinable var symbol: Ion.Symbol {
        switch self {
        case .imports: .imports
        case .symbols: .symbols
        }
    }
}
