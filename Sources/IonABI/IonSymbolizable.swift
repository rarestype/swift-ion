public protocol IonSymbolizable: CustomStringConvertible, Sendable {
    var symbol: Ion.Symbol { get }
    func get(in symbols: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID?
    func set(in symbols: inout Ion.SymbolEncoder) -> Ion.Symbol.ID
}
extension IonSymbolizable {
    @inlinable public var description: String { "\(self.symbol)" }
}
extension IonSymbolizable where Self: RawRepresentable<String> {
    @inlinable public var symbol: Ion.Symbol { .init(self.rawValue) }

    @inlinable public func get(in symbols: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID? {
        symbols[self.symbol]
    }
    @inlinable public func set(in symbols: inout Ion.SymbolEncoder) -> Ion.Symbol.ID {
        symbols[self.symbol]
    }
}
/// System symbols completely bypass symbol tables.
extension IonSymbolizable where Self: Identifiable<Ion.Symbol.ID> {
    @inlinable public func get(in _: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID? { self.id }
    @inlinable public func set(in _: inout Ion.SymbolEncoder) -> Ion.Symbol.ID { self.id }
}
