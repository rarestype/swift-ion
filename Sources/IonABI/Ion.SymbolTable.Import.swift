extension Ion.SymbolTable {
    @frozen @usableFromInline struct Import {
        let name: String
        let version: UInt
        let max_id: Ion.Symbol?
    }
}
extension Ion.SymbolTable.Import: IonEncodableStruct {
    @usableFromInline func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.name] = self.name
        ion[.version] = self.version
        ion[.max_id] = self.max_id
    }
}
extension Ion.SymbolTable.Import: IonDecodableStruct {
    @usableFromInline init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.init(
            name: try ion[.name]?.decode() ?? "",
            version: max(1, try ion[.version]?.decode() ?? 1),
            max_id: try ion[.max_id]?.decode()
        )
    }
}
