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
            switch number {
            case .decimal(let number):
                value = .decimal(number)
            case .float(let number):
                value = .float(number)
            case .int(let sign, let magnitude):
                value = .int(sign, magnitude)
            case .unrepresentable(let string):
                throw .arbitrary(Ion.InvalidNumberError.unsupported(string))
            }
        } else if
            let string: String = input.parse(as: AST.StringRule<Location>?.self) {
            value = .string(string)
        } else if
            let `struct`: AST.Struct = input.parse(as: Object?.self) {
            value = .struct(`struct`)
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
            let float: Float = input.parse(as: AST.NodeRule<Location>.Nonfinite?.self) {
            value = .float(.float32(float))
        } else {
            try input.parse(as: Null.self)
            value = .null(.null)
        }

        return .init(types: nil, value: value)
    }
}
