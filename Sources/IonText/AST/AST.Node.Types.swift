extension AST.Node {
    struct Types: Equatable, Sendable {
        var first: AST.Symbol
        var extra: [AST.Symbol]

        init(first: AST.Symbol, extra: [AST.Symbol] = []) {
            self.first = first
            self.extra = extra
        }
    }
}
