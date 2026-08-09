internal import Grammar

extension AST {
    enum RootRule<Location> {}
}
extension AST.RootRule: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Node
        where Source.Element == Terminal, Source.Index == Location {
        let value: AST.AnyValue
        if  let `struct`: AST.Struct = input.parse(as: AST.NodeRule<Location>.Object?.self) {
            value = .struct(`struct`)
        } else {
            value = .list(try input.parse(as: AST.NodeRule<Location>.Array.self))
        }
        return .init(types: nil, value: value)
    }
}
