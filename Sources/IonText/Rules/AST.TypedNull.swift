internal import Grammar
import IonABI

extension AST {
    /// Matches a `null` literal, optionally followed by a type qualifier
    /// (e.g., `null.int`, `null.string`).
    enum TypedNull<Location> {}
}
extension AST.TypedNull: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = AST.AnyValue

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.AnyValue
        where Source.Element == Terminal, Source.Index == Location {
        typealias IdentifierContinue = AST.SymbolRule<Location>.IdentifierSymbol.Continue
        try input.parse(as: NullPrefix.self)
        if input.parse(as: Dot?.self) == nil {
            if let _: Void = input.parse(as: IdentifierContinue?.self) {
                throw .unexpectedValue
            }
            return .null(.null)
        }
        let start: Location = input.index
        input.parse(as: TypeName.self, in: Void.self)
        let end: Location = input.index
        guard end > start else {
            throw .unexpectedValue
        }
        if let _: Void = input.parse(as: IdentifierContinue?.self) {
            throw .unexpectedValue
        }
        switch String.init(decoding: input[start ..< end], as: Unicode.UTF8.self) {
        case "bool": return .null(.bool)
        case "int": return .null(.int(.positive))
        case "float": return .null(.float)
        case "decimal": return .null(.decimal)
        case "timestamp": return .null(.timestamp)
        case "symbol": return .null(.symbol)
        case "string": return .null(.string)
        case "clob": return .null(.clob)
        case "blob": return .null(.blob)
        case "list": return .null(.list)
        case "sexp": return .null(.sexp)
        case "struct": return .null(.struct)
        case "null": return .null(.null)
        default: throw .unexpectedValue
        }
    }
}
