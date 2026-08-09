import IonABI

extension AST {
    struct Struct {
        let fields: [(key: Symbol, value: Node)]
    }
}
extension AST.Struct: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<AST.Symbol>) {
        for (id, value): (AST.Symbol, AST.Node) in self.fields {
            ion[id] = value
        }
    }
}
