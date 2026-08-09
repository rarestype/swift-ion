internal import Grammar
import IonABI

extension AST {
    struct Node {
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

            ion.wrap(as: types, with: self.value.encode(to:))
        } else {
            self.value.encode(to: &ion)
        }
    }
}
extension AST.Node {
    init(parsing span: borrowing RawSpan) throws(PatternMatchingError) {
        self = try span.withUnsafeBytes(AST.NodeRule<Int>.parse(_:))
    }
    init(parsing string: borrowing String) throws(PatternMatchingError) {
        self = try AST.NodeRule<String.Index>.parse(string.utf8)
    }
    init(parsing string: borrowing Substring) throws(PatternMatchingError) {
        self = try AST.NodeRule<String.Index>.parse(string.utf8)
    }
}
