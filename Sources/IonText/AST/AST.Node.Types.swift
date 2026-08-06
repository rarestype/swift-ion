extension AST.Node {
    struct Types: Equatable, Sendable {
        var first: AST.SymbolKey
        var extra: [AST.SymbolKey]

        init(first: AST.SymbolKey, extra: [AST.SymbolKey] = []) {
            self.first = first
            self.extra = extra
        }
    }
}
