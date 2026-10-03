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
            let name: String = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            if name == "bool" { return .null(.bool) }
            if name == "int" { return .null(.int(.positive)) }
            if name == "float" { return .null(.float) }
            if name == "decimal" { return .null(.decimal) }
            if name == "timestamp" { return .null(.timestamp) }
            if name == "symbol" { return .null(.symbol) }
            if name == "string" { return .null(.string) }
            if name == "clob" { return .null(.clob) }
            if name == "blob" { return .null(.blob) }
            if name == "list" { return .null(.list) }
            if name == "sexp" { return .null(.sexp) }
            if name == "struct" { return .null(.struct) }
            if name == "null" { return .null(.null) }
            throw .unexpectedValue
        }
    }
}
