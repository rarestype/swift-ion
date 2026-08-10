extension Ion {
    @frozen public struct NodeDecoder: ~Copyable  {
        @usableFromInline let table: SymbolDecoder
        public let value: AnyValue
        public let types: Node.Types?
        @inlinable init(
            table: consuming SymbolDecoder,
            value: AnyValue,
            types: Node.Types?,
        ) {
            self.table = table
            self.value = value
            self.types = types
        }
    }
}
extension Ion.NodeDecoder {
    @inlinable init(table: consuming Ion.SymbolDecoder, node: Ion.Node) {
        self.init(table: table, value: node.value, types: node.types)
    }

    @inline(always) @inlinable public var symbol: Ion.SymbolDecoder {
        _read { yield self.table }
    }
}
extension Ion.NodeDecoder {
    @inline(always) @inlinable func bind<Decoder, T>(
        to _: Decoder.Type = Decoder.self,
        with yield: (borrowing Decoder) throws -> T
    ) throws -> T where Decoder: ~Copyable & Ion.Decoder, T: ~Copyable {
        try yield(try Decoder.acquire(context: self._withoutActuallyEscaping()))
    }
    @inline(always) @inlinable func bind<Decoder, T>(
        to _: Decoder.Type = Decoder.self,
        with yield: (inout Decoder) throws -> T
    ) throws -> T where Decoder: ~Copyable & Ion.Decoder, T: ~Copyable {
        var decoder: Decoder = try .acquire(context: self._withoutActuallyEscaping())
        return try yield(&decoder)
    }
}
extension Ion.NodeDecoder {
    /// Obtain a copy of the decoder, trusting that the caller will not escape it from the
    /// scope where the original decoder is available. For maximum performance, it should only
    /// be stored in other noncopyable types that are passed as immutable `borrowing` arguments
    /// to user-provided closures.
    ///
    /// If the value escapes, it is not the end of the world, it will just be slow because the
    /// compiler will be forced to defensively increment the refcount of the underlying symbol
    /// table.
    @inline(always) @inlinable func _withoutActuallyEscaping() -> Self {
        .init(
            table: self.table._withoutActuallyEscaping(),
            value: self.value,
            types: self.types
        )
    }
}
