extension Ion {
    @frozen public struct StructEncoder<CodingKey>: ~Copyable
        where CodingKey: IonSymbolizable {
        @usableFromInline var base: NodeEncoder
        @inlinable init(base: consuming NodeEncoder) {
            self.base = base
        }
    }
}
extension Ion.StructEncoder: Ion.Encoder {
    @inlinable static var type: Ion.AnyType { .struct }
    @inlinable static func acquire(context: consuming Ion.NodeEncoder) -> Self {
        .init(base: context)
    }
    @inlinable consuming func release() -> Ion.NodeEncoder {
        self.base
    }
}
extension Ion.StructEncoder {
    @inlinable public subscript(with field: CodingKey) -> Ion.NodeEncoder {
        mutating _read {
            let id: Ion.Symbol.ID = field.set(in: &self.base.table)
            self.base.output.write(field: id)
            defer { self.base.output.write(padding: 1) }
            yield self.base
        }

        _modify {
            let id: Ion.Symbol.ID = field.set(in: &self.base.table)
            self.base.output.write(field: id)
            yield &self.base
        }
    }
}
extension Ion.StructEncoder {
    @inlinable public subscript<E, T, NestedKey>(
        outer: CodingKey,
        inner: NestedKey.Type = NestedKey.self,
        yield: (inout Ion.StructEncoder<NestedKey>) throws(E) -> T
    ) -> T {
        mutating get throws(E) {
            try self[with: outer].bind(with: yield)
        }
    }

    @inlinable public subscript<E, T>(
        outer: CodingKey,
        yield: (inout Ion.ListEncoder) throws(E) -> T
    ) -> T {
        mutating get throws(E) {
            try self[with: outer].bind(with: yield)
        }
    }

    @inlinable public subscript<Encodable>(
        field: CodingKey
    ) -> Encodable? where Encodable: IonEncodable & ~Copyable {
        get { nil }
        set (value) { value?.encode(to: &self[with: field]) }
    }
}
