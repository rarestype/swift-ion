extension Ion {
    @frozen public struct SymbolDecoder: ~Copyable {
        @usableFromInline var reverse: [Ion.Symbol: Ion.Symbol.ID]
        @usableFromInline var symbols: [Ion.Symbol]
        @inlinable init(
            reverse: [Ion.Symbol: Ion.Symbol.ID],
            symbols: [Ion.Symbol]
        ) {
            self.reverse = reverse
            self.symbols = symbols
        }
    }
}
extension Ion.SymbolDecoder {
    @inlinable static var _system: Self { .init(reverse: [:], symbols: []) }
}
extension Ion.SymbolDecoder {
    @inlinable init(local: consuming [Ion.Symbol]) {
        var reverse: [Ion.Symbol: Ion.Symbol.ID] = [
            ._ion: ._ion,
            ._ion_1_0: ._ion_1_0,
            ._ion_symbol_table: ._ion_symbol_table,
            .name: .name,
            .version: .version,
            .imports: .imports,
            .symbols: .symbols,
            .max_id: .max_id,
            ._ion_shared_symbol_table: ._ion_shared_symbol_table,
        ]

        reverse.reserveCapacity(10 + local.count)

        var cursor: Ion.Symbol.ID = 10
        for symbol: Ion.Symbol in copy local {
            reverse[symbol] = cursor
            cursor = cursor.successor
        }

        self.init(reverse: reverse, symbols: local)
    }
}
extension Ion.SymbolDecoder {
    /// Obtain a copy of the symbol table, trusting that the caller will not escape it from the
    /// scope where the original table is available. For maximum performance, it should only be
    /// stored in other noncopyable types that are passed as immutable `borrowing` arguments
    /// to user-provided closures.
    ///
    /// If the value escapes, it is not the end of the world, it will just be slow because the
    /// compiler will be forced to defensively increment the refcount of the underlying symbol
    /// table.
    @inline(always) @inlinable func _withoutActuallyEscaping() -> Self {
        .init(reverse: self.reverse, symbols: self.symbols)
    }
}
extension Ion.SymbolDecoder {
    @inlinable subscript(symbol: Ion.Symbol) -> Ion.Symbol.ID? {
        self.reverse[symbol]
    }
    @inlinable subscript(id: Ion.Symbol.ID) -> Ion.Symbol? {
        if  let symbol: Ion.Symbol = id.system {
            return symbol
        }

        let offset: Int = id.user
        if  offset < self.symbols.endIndex {
            return self.symbols[id.user]
        } else {
            return nil
        }
    }
}
