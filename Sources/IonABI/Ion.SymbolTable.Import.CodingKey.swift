internal import Bijection

extension Ion.SymbolTable.Import {
    @frozen @usableFromInline enum CodingKey {
        case name
        case version
        case max_id
    }
}
extension Ion.SymbolTable.Import.CodingKey: Identifiable {
    @Bijection(label: "id") @inlinable var id: Ion.Symbol.ID {
        switch self {
        case .name: .name
        case .version: .version
        case .max_id: .max_id
        }
    }
}
extension Ion.SymbolTable.Import.CodingKey: IonSymbolizable {
    @inlinable var symbol: Ion.Symbol {
        switch self {
        case .name: .name
        case .version: .version
        case .max_id: .max_id
        }
    }
}
