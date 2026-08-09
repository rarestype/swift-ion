import IonABI

extension AST {
    struct Sexp {
        let elements: [Node]
    }
}
extension AST.Sexp: IonEncodableSexp {
    func encode(to ion: inout Ion.ListEncoder) {
        for element: AST.Node in self.elements {
            element.encode(to: &ion[with: +])
        }
    }
}
