internal import Grammar

extension AST.LongString {
    /// Matches an unescaped newline sequence in a long string literal:
    /// `\n`, `\r\n`, or `\r`.
    enum Newline {}
}
extension AST.LongString.Newline: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> Void
        where Source.Element == Terminal, Source.Index == Location {
        typealias ASCII = UnicodeEncoding<Location, UInt8>
        if let _: Void = input.parse(as: ASCII.Linefeed?.self) {
            return
        }
        try input.parse(as: ASCII.CarriageReturn.self)
        let _: Void? = input.parse(as: ASCII.Linefeed?.self)
    }
}
