extension Ion {
    @frozen public struct Symbol: Sendable {
        @usableFromInline let utf8: String.UTF8View
        @inlinable init(utf8: String.UTF8View) {
            self.utf8 = utf8
        }
    }
}
extension Ion.Symbol {
    @inlinable public static var _ion: Self { "$ion" }
    @inlinable public static var _ion_1_0: Self { "$ion_1_0" }
    @inlinable public static var _ion_symbol_table: Self { "$ion_symbol_table" }
    @inlinable public static var name: Self { "name" }
    @inlinable public static var version: Self { "version" }
    @inlinable public static var imports: Self { "imports" }
    @inlinable public static var symbols: Self { "symbols" }
    @inlinable public static var max_id: Self { "max_id" }
    @inlinable public static var _ion_shared_symbol_table: Self { "$ion_shared_symbol_table" }
}
extension Ion.Symbol {
    @inlinable var system: ID? {
        switch self {
        case ._ion: ._ion
        case ._ion_1_0: ._ion_1_0
        case ._ion_symbol_table: ._ion_symbol_table
        case .name: .name
        case .version: .version
        case .imports: .imports
        case .symbols: .symbols
        case .max_id: .max_id
        case ._ion_shared_symbol_table: ._ion_shared_symbol_table
        default: nil
        }
    }
}
extension Ion.Symbol: Equatable {
    @inlinable public static func == (a: Self, b: Self) -> Bool { a.utf8.elementsEqual(b.utf8) }
}
extension Ion.Symbol: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool {
        a.utf8.lexicographicallyPrecedes(b.utf8)
    }
}
extension Ion.Symbol: Hashable {
    @inlinable public func hash(into hasher: inout Hasher) {
        for unit: UInt8 in self.utf8 {
            unit.hash(into: &hasher)
        }
    }
}
extension Ion.Symbol: CustomStringConvertible {
    @inlinable public var description: String { .init(self.utf8) }
}
extension Ion.Symbol: LosslessStringConvertible {
    @inlinable public init(_ string: String) {
        self.init(utf8: string.utf8)
    }
}
extension Ion.Symbol: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) {
        self.init(utf8: stringLiteral.utf8)
    }
}
extension Ion.Symbol: IonEncodableString, IonDecodableString {}
