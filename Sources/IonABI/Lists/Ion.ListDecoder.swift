extension Ion {
    @frozen public struct ListDecoder: ~Copyable {
        @usableFromInline let table: Ion.SymbolDecoder
        @usableFromInline var index: Int
        @usableFromInline var input: List.Iterator?

        @inlinable init(
            table: consuming Ion.SymbolDecoder,
            input: List.Iterator
        ) {
            self.table = table
            self.index = 0
            self.input = input
        }
    }
}
extension Ion.ListDecoder: Ion.Decoder {
    @inlinable static func acquire(
        context: consuming Ion.NodeDecoder,
    ) throws -> Self {
        let list: Ion.List = try .init(ion: context)
        return .init(table: context.table, input: list.values)
    }
}
extension Ion.ListDecoder {
    @inlinable public var position: Int { self.index }

    @_disfavoredOverload
    @inlinable public subscript(_: (Ion.EndIndex) -> ()) -> FieldAccessor {
        mutating _read {
            do {
                guard
                let node: Ion.Node = try self.input?.next() else {
                    yield .init(id: self.index, value: .success(nil))
                    return
                }
                defer {
                    self.index += 1
                }
                let local: Ion.NodeDecoder = .init(
                    table: self.table._withoutActuallyEscaping(),
                    node: node,
                )
                yield .init(id: self.index, value: .success(local))
            } catch let error {
                self.input = nil
                yield .init(id: self.index, value: .failure(error))
            }
        }
    }

    @inlinable public subscript(_: (Ion.EndIndex) -> ()) -> Field? {
        mutating _read {
            do {
                guard
                let node: Ion.Node = try self.input?.next() else {
                    yield nil
                    return
                }
                defer {
                    self.index += 1
                }
                let local: Ion.NodeDecoder = .init(
                    table: self.table._withoutActuallyEscaping(),
                    node: node,
                )
                yield .init(id: self.index, value: .success(local))
            } catch let error {
                self.input = nil
                yield .init(id: self.index, value: .failure(error))
            }
        }
    }
}
