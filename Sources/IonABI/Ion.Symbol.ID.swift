extension Ion.Symbol {
    @frozen public struct ID: RawRepresentable, Hashable, Equatable, Sendable {
        public let rawValue: UInt32
        @inlinable public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
extension Ion.Symbol.ID: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral: UInt32) {
        self.init(rawValue: integerLiteral)
    }
}
extension Ion.Symbol.ID: CustomStringConvertible {
    public var description: String { "$\(self.rawValue)" }
}
extension Ion.Symbol.ID: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}
extension Ion.Symbol.ID {
    @inlinable public static var _ion: Self { 1 }
    @inlinable public static var _ion_1_0: Self { 2 }
    @inlinable public static var _ion_symbol_table: Self { 3 }
    @inlinable public static var name: Self { 4 }
    @inlinable public static var version: Self { 5 }
    @inlinable public static var imports: Self { 6 }
    @inlinable public static var symbols: Self { 7 }
    @inlinable public static var max_id: Self { 8 }
    @inlinable public static var _ion_shared_symbol_table: Self { 9 }

    @inlinable static subscript(user offset: Int) -> Self {
        .init(rawValue: 10 + UInt32.init(offset) )
    }
}
extension Ion.Symbol.ID {
    /// Returns the user offset of the symbol, or a negative number if the symbol is a system
    /// symbol.
    @inlinable var user: Int { Int.init(self.rawValue) - 10 }
    @inlinable var system: Ion.Symbol? {
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
extension Ion.Symbol.ID {
    @inlinable var successor: Self { .init(rawValue: self.rawValue + 1) }
}
extension Ion.Symbol.ID {
    public typealias NullGroup = Self
}
extension Ion.Symbol.ID: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        guard self != 0 else {
            ion.output[type: .symbol, size: 0]
            return
        }

        let size: Int = self.rawValue.bytesSpanned

        ion.output[type: .symbol, size: size]
        ion.output.write(fixed: self.rawValue, octets: size)
    }
}
extension Ion.Symbol.ID: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.symbol)
    }
}
extension Ion.Symbol.ID: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .symbol }
}
