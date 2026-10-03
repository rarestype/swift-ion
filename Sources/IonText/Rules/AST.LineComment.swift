internal import Grammar

extension AST {
    /// Matches a line comment: `//` followed by any characters until end of line.
    ///
    /// The terminating newline (if any) is not consumed.
    enum LineComment<Location> {}
}
extension AST.LineComment: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> Void
        where Source.Element == Terminal, Source.Index == Location {
        try input.parse(as: Prefix.self)
        input.parse(as: Continuation.self, in: Void.self)
    }
}
