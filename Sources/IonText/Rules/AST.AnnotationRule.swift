internal import Grammar
import IonABI

extension AST {
    /// Matches an annotated value: one or more `symbol::` prefixes followed by a value.
    enum AnnotationRule<Location> {}
}
extension AST.AnnotationRule: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = AST.Node

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Node
        where Source.Element == Terminal, Source.Index == Location {
        typealias Delimiter = Pattern.Pad<DoubleColon, AST.WhitespaceRule<Location>>
        typealias Item = (Prefix, Delimiter)

        let (first, _): (AST.Symbol, Void) = try input.parse(as: Item.self)
        var annotations: [AST.Symbol] = [first]
        while let (annotation, _): (AST.Symbol, Void) = try? input.parse(as: Item.self) {
            annotations.append(annotation)
        }
        let value: AST.Node = try input.parse(as: AST.NodeRule<Location>.self)
        let allAnnotations: [AST.Symbol]
        if let existing: AST.Node.Types = value.types {
            allAnnotations = annotations + [existing.first] + existing.extra
        } else {
            allAnnotations = annotations
        }
        let types: AST.Node.Types = .init(
            first: allAnnotations[0],
            extra: Array.init(allAnnotations.dropFirst())
        )
        return .init(types: types, value: value.value)
    }
}
