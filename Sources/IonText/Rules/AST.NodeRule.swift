internal import Grammar
import IonABI

extension AST {
    /// Matches any value, including fragment values.
    ///
    /// Only use this if you are doing manual AST parsing. Most web services
    /// should send complete ``AST.RootRule`` messages through their public APIs.
    enum NodeRule<Location> {}
}
extension AST.NodeRule: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Node
        where Source.Element == Terminal, Source.Index == Location {
        let value: AST.AnyValue
        if  let number: AST.Number = input.parse(as: AST.NumberRule<Location>?.self) {
            value = .number(number)
        } else if
            let string: String = input.parse(as: AST.StringRule<Location>?.self) {
            value = .string(string)
        } else if
            let items: [(AST.SymbolKey, AST.Node)] = input.parse(as: Object?.self) {
            value = .struct(items)
        } else if
            let elements: [AST.Node] = input.parse(as: Array?.self) {
            value = .list(elements)
        } else if
            let _: Void = input.parse(as: True?.self) {
            value = .bool(true)
        } else if
            let _: Void = input.parse(as: False?.self) {
            value = .bool(false)
        } else if
            let number: AST.Number = input.parse(as: AST.NodeRule<Location>.Nonfinite?.self) {
            value = .number(number)
        } else {
            try input.parse(as: Null.self)
            value = .null(.null)
        }

        return .init(types: nil, value: value)
    }
}
