internal import Grammar
import IonABI

extension AST {
    /// Matches a `null` literal, optionally followed by a type qualifier
    /// (e.g., `null.int`, `null.string`).
    enum TypedNull<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = AST.AnyValue

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> AST.AnyValue
            where Source.Element == Terminal, Source.Index == Location {
            try input.parse(as: NullPrefix.self)
            if input.parse(as: Dot?.self) == nil {
                return .null(.null)
            }
            let start: Location = input.index
            input.parse(as: TypeName.self, in: Void.self)
            let end: Location = input.index
            guard end > start else {
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
}
