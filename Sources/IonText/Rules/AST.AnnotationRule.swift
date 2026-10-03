internal import Grammar
import IonABI

extension AST {
    /// Matches an annotated value: one or more `symbol::` prefixes followed by a value.
    ///
    /// If the input does not begin with `symbol::`, this rule fails without
    /// consuming input.
    enum AnnotationRule<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = AST.Node

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> AST.Node
            where Source.Element == Terminal, Source.Index == Location {
            let saved: Location = input.index
            guard let first: AST.Symbol = input.parse(as: Prefix?.self),
                  input.parse(as: DoubleColon?.self) != nil
            else {
                input.index = saved
                throw .unexpectedValue
            }
            var annotations: [AST.Symbol] = [first]
            while let sym: AST.Symbol = input.parse(as: Prefix?.self),
                  input.parse(as: DoubleColon?.self) != nil {
                annotations.append(sym)
            }
            input.parse(as: WhitespaceRule<Location>.self, in: Void.self)
            let value: AST.Node = try input.parse(as: NodeRule<Location>.self)
            let types: AST.Node.Types
            if annotations.count == 1 {
                types = .init(first: annotations[0])
            } else {
                types = .init(first: annotations[0], extra: Array.init(annotations.dropFirst()))
            }
            return .init(types: types, value: value.value)
        }
    }
}
