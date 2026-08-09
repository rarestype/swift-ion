extension Ion {
    @frozen public struct StructCursor: ~Copyable {
        @usableFromInline let table: Ion.SymbolDecoder
        @usableFromInline var input: Struct.Iterator?
        @inlinable init(
            table: consuming Ion.SymbolDecoder,
            input: Struct.Iterator,
        ) {
            self.table = table
            self.input = input
        }
    }
}
extension Ion.StructCursor: Ion.Decoder {
    @inlinable static func acquire(context: consuming Ion.NodeDecoder) throws -> Self {
        let structure: Ion.Struct = try .init(ion: context)
        return .init(table: context.table, input: structure.fields)
    }
}
extension Ion.StructCursor {
    @inlinable public subscript(_: (Ion.EndIndex) -> ()) -> Field? {
        mutating _read {
            let next: (id: Ion.Symbol.ID, node: Ion.Node)?
            do {
                next = try self.input?.next()
            } catch {
                self.input = nil
                yield nil
                return
            }

            guard
            let next: (id: Ion.Symbol.ID, node: Ion.Node),
            let key: Ion.Symbol = self.table[next.id] else {
                yield nil
                return
            }

            let local: Ion.NodeDecoder = .init(
                table: self.table._withoutActuallyEscaping(),
                node: next.node,
            )
            yield .init(id: key, value: local)
        }
    }
}
