extension Ion {
    @frozen public struct Node {
        public var types: Types?
        public var value: AnyValue

        @inlinable public init(types: Types? = nil, value: AnyValue) {
            self.types = types
            self.value = value
        }
    }
}
extension Ion.Node {
    @inlinable public func decode<Decodable>(
        to _: Decodable.Type = Decodable.self,
        with table: borrowing Ion.SymbolDecoder
    ) throws -> Decodable where Decodable: IonDecodable & ~Copyable {
        let decoder: Ion.NodeDecoder = .init(
            table: table._withoutActuallyEscaping(),
            value: self.value,
            types: self.types
        )

        return try .init(ion: decoder)
    }
}
