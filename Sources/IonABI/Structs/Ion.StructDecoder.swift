extension Ion {
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for an ``Ion/Struct``.
    @frozen public struct StructDecoder<CodingKey>: ~Copyable
        where CodingKey: IonSymbolizable {
        @usableFromInline let table: Ion.SymbolDecoder
        @usableFromInline var index: [Symbol.ID: Node]
        @inlinable init(
            table: consuming Ion.SymbolDecoder,
            index: [Symbol.ID: Node] = [:],
        ) {
            self.table = table
            self.index = index
        }
    }
}
extension Ion.StructDecoder: Ion.Decoder {
    @inlinable static func acquire(context: consuming Ion.NodeDecoder) throws -> Self {
        let structure: Ion.Struct = try .init(ion: context)
        return .init(table: context.table, index: try structure.parsed)
    }
}
extension Ion.StructDecoder {
    @inlinable public subscript(key: CodingKey) -> FieldAccessor {
        _read {
            guard let id: Ion.Symbol.ID = key.get(in: self.table) else {
                // symbols are global, so we eagerly render the key to prepare the diagnostic
                yield .init(id: key, value: .failure(.undefined(key)))
                return
            }
            if  let node: Ion.Node = self.index[id] {
                let local: Ion.NodeDecoder = .init(
                    table: self.table._withoutActuallyEscaping(),
                    node: node,
                )
                yield .init(id: key, value: .success(local))
            } else {
                yield .init(id: key, value: .success(nil))
            }
        }
    }
    @inlinable public subscript(key: CodingKey) -> Field? {
        _read {
            guard let id: Ion.Symbol.ID = key.get(in: self.table) else {
                yield nil
                return
            }
            if  let node: Ion.Node = self.index[id] {
                let local: Ion.NodeDecoder = .init(
                    table: self.table._withoutActuallyEscaping(),
                    node: node,
                )
                yield .init(id: key, value: .success(local))
            } else {
                yield nil
            }
        }
    }
}
