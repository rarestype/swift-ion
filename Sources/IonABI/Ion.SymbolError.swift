extension Ion {
    @frozen public enum SymbolError: Error {
        case undefined(String)
    }
}
extension Ion.SymbolError {
    @inlinable static func undefined(_ symbol: some IonSymbolizable) -> Self {
        .undefined("\(symbol)")
    }
}
extension Ion.SymbolError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undefined(let symbol): "undefined symbol '\(symbol)'"
        }
    }
}
