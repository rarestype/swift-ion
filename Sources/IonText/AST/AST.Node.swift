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
extension AST {
    /// Matches a complete Ion text value, including leading and trailing
    /// whitespace and comments.
    enum RootRule<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = AST.Node

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> AST.Node
            where Source: Collection<Terminal>, Source.Index == Location {
            input.parse(as: WhitespaceRule<Location>.self, in: Void.self)
            let node: AST.Node = try input.parse(as: NodeRule<Location>.self)
            input.parse(as: WhitespaceRule<Location>.self, in: Void.self)
            return node
        }
    }
}
extension AST.Node {
    init(parsing span: borrowing RawSpan) throws(PatternMatchingError) {
        self = try span.withUnsafeBytes(AST.RootRule<Int>.parse(_:))
    }
    init(parsing string: borrowing String) throws(PatternMatchingError) {
        self = try AST.RootRule<String.Index>.parse(string.utf8)
    }
    init(parsing string: borrowing Substring) throws(PatternMatchingError) {
        self = try AST.RootRule<String.Index>.parse(string.utf8)
    }
}
