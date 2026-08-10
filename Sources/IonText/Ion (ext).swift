public import IonABI
internal import Grammar

extension Ion {
    public static func parse(atomic span: RawSpan) throws -> Self {
        let node: AST.Node = try .init(parsing: span)
        return .encode(atomic: node)
    }
    public static func parse(atomic string: String) throws -> Self {
        let node: AST.Node = try .init(parsing: string)
        return .encode(atomic: node)
    }
    public static func parse(atomic string: Substring) throws -> Self {
        let node: AST.Node = try .init(parsing: string)
        return .encode(atomic: node)
    }
}
