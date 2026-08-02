extension Ion {
    @frozen public struct Node {
        @usableFromInline var types: Types?
        @usableFromInline var value: AnyValue
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
