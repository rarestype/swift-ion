internal import Grammar

extension AST.LongString {
    /// Matches a backslash immediately followed by a newline sequence,
    /// representing a line continuation that produces no characters.
    enum LineContinuation {}
}
extension AST.LongString.LineContinuation: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> Void
        where Source.Element == Terminal, Source.Index == Location {
        typealias ASCII = UnicodeEncoding<Location, UInt8>
        try input.parse(as: ASCII.Backslash.self)
        try input.parse(as: AST.LongString<Location>.Newline.self)
    }
}
