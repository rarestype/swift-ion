extension Ion {
    @frozen public struct ListEncoder: ~Copyable {
        @usableFromInline var base: NodeEncoder
        @inlinable init(base: consuming NodeEncoder) {
            self.base = base
        }
    }
}
extension Ion.ListEncoder: Ion.Encoder {
    @inlinable static var type: Ion.AnyType { .list }
    @inlinable static func acquire(context: consuming Ion.NodeEncoder) -> Self {
        .init(base: context)
    }
    @inlinable consuming func release() -> Ion.NodeEncoder {
        self.base
    }
}
extension Ion.ListEncoder {
    @inlinable public subscript(with _: (Ion.EndIndex) -> ()) -> Ion.NodeEncoder {
        _read   { yield  self.base }
        _modify { yield &self.base }
    }
}
// we could make the closure literal encoding apis support `T: ~Copyable`, but then they would
// be supporting something that ``Ion.StructEncoder`` does not, so we don’t.
extension Ion.ListEncoder {
    @inlinable public mutating func callAsFunction<E, T, CodingKey>(
        inner _: CodingKey.Type = CodingKey.self,
        yield: (inout Ion.StructEncoder<CodingKey>) throws(E) -> T
    ) throws(E) -> T {
        try self[with: +].bind(with: yield)
    }

    @inlinable public mutating func callAsFunction<E, T>(
        yield: (inout Ion.ListEncoder) throws(E) -> T
    ) throws(E) -> T {
        try self[with: +].bind(with: yield)
    }

    @inlinable public subscript<Encodable>(
        _: (Ion.EndIndex) -> ()
    ) -> Encodable? where Encodable: IonEncodable & ~Copyable {
        get { nil }
        set (value) { value?.encode(to: &self[with: +]) }
    }
}
