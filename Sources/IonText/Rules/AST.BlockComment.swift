internal import Grammar

extension AST {
    /// Matches a block comment: `/* ... */`, supporting nesting.
    enum BlockComment<Location> {}
}
extension AST.BlockComment: ParsingRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> Void
        where Source.Element == Terminal, Source.Index == Location {
        try input.parse(as: Prefix.self)
        var depth: Int = 1
        while depth > 0 {
            if let _: Void = input.parse(as: Prefix?.self) {
                depth += 1
                continue
            }
            if let _: Void = input.parse(as: Suffix?.self) {
                depth -= 1
                continue
            }
            guard let _: UInt8 = input.next() else {
                throw .unexpectedEndOfInput
            }
        }
    }
}
