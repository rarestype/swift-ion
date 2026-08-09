public protocol IonSymbolizable: CustomStringConvertible, Sendable {
    func get(in symbols: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID?
    func set(in symbols: inout Ion.SymbolEncoder) -> Ion.Symbol.ID
}
extension IonSymbolizable where Self: RawRepresentable<String> {
    @inlinable public func get(in symbols: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID? {
        symbols[self.symbol]
    }
    @inlinable public func set(in symbols: inout Ion.SymbolEncoder) -> Ion.Symbol.ID {
        symbols[self.symbol]
    }

    @inlinable public var description: String { self.rawValue }
    @inlinable var symbol: Ion.Symbol { .init(self.rawValue) }
}
extension IonSymbolizable where Self: Ion.SymbolConvertible {
    @inlinable var description: String { "\(self.symbol)" }
}
/// System symbols completely bypass symbol tables.
extension IonSymbolizable where Self: Identifiable<Ion.Symbol.ID> {
    @inlinable public func get(in _: borrowing Ion.SymbolDecoder) -> Ion.Symbol.ID? { self.id }
    @inlinable public func set(in _: inout Ion.SymbolEncoder) -> Ion.Symbol.ID { self.id }
}
