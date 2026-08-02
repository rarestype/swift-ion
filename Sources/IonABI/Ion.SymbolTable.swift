extension Ion {
    @frozen @usableFromInline struct SymbolTable {
        @usableFromInline var imports: [Import]
        @usableFromInline var symbols: [Ion.Symbol]

        @inlinable init(
            imports: [Import],
            symbols: [Ion.Symbol],
        ) {
            self.imports = imports
            self.symbols = symbols
        }
    }
}
extension Ion.SymbolTable: IonEncodableStruct {
    @usableFromInline func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.imports] = self.imports
        ion[.symbols] = self.symbols
    }
}
extension Ion.SymbolTable: IonDecodableStruct {
    @usableFromInline init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.init(
            imports: try ion[.imports]?.decode() ?? [],
            symbols: try ion[.symbols]?.decode() ?? [],
        )
    }
}
