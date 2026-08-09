import IonABI

extension AST {
    struct List: Sendable {
        let elements: [Node]
    }
}
extension AST.List: IonEncodableList {
    func encode(to ion: inout Ion.ListEncoder) {
        self.elements.encode(to: &ion)
    }
}
