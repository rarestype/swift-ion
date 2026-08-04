@frozen public struct Ion {
    @usableFromInline var _bytes: ArraySlice<UInt8>
    @inlinable public init(bytes: ArraySlice<UInt8>) {
        self._bytes = bytes
    }
}
extension Ion {
    @inline(always) @inlinable static var v1_0: (UInt8, UInt8, UInt8) { (0x01, 0x00, 0xea) }
    @inline(always) @inlinable public var bytes: ArraySlice<UInt8> { self._bytes }
}
extension Ion {
    @inlinable public static func encode<Encodable>(
        atomic value: borrowing Encodable,
    ) -> Self where Encodable: IonEncodable & ~Copyable {
        var inner: NodeEncoder = .init(table: .init(), output: .init(capacity: 16))

        value.encode(to: &inner)

        var outer: NodeEncoder = .init(table: .init(), output: .init(capacity: 16))
        outer.output.append(Node.Types.mask)
        outer.output.append(self.v1_0.0)
        outer.output.append(self.v1_0.1)
        outer.output.append(self.v1_0.2)
        outer.output[types: ._ion_symbol_table, symbols: []] = inner.table.move

        var buffer: [UInt8] = (consume outer).output.move()

        inner.output.move(into: &buffer)

        return .init(bytes: buffer[...])
    }

    @inlinable public func decode<Decodable>(
        atomic _: Decodable.Type = Decodable.self
    ) throws -> Decodable where Decodable: IonDecodable & ~Copyable {
        var input: Input = .init(self.bytes)

        guard case .v1_0 = try input.parseOuter() else {
            throw MessageFormatError.expectedIVM
        }

        var table: SymbolTable? = nil

        while let node: TopLevelNode = try input.parseOuter() {
            guard case .node(let node) = node else {
                // another IVM clears the symbol table, if one was set for some reason
                // this is wasteful, but legal
                table = nil
                continue
            }
            if  case nil = table,
                case ._ion_symbol_table? = node.types?.first {
                table = try node.decode(with: ._system)
            } else {
                return try node.decode(with: .init(local: table?.symbols ?? []))
            }
        }

        throw MessageFormatError.expectedBody
    }
}
