import IonABI

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
extension AST.Node: IonEncodable {
    func encode(to ion: inout Ion.NodeEncoder) {
        if  let types: Types = self.types {
            let types: Ion.Node.Types = .init(
                first: types.first.set(in: &ion.symbol),
                extra: types.extra.map { $0.set(in: &ion.symbol) }
            )

            ion._wrap(as: types, with: self.value.encode(to:))
        } else {
            self.value.encode(to: &ion)
        }
    }
}
