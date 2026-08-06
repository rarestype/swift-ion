extension AST {
    struct Node: Sendable {
        var types: Types?
        var value: AnyValue

        init(types: Types? = nil, value: AnyValue) {
            self.types = types
            self.value = value
        }
    }
}
