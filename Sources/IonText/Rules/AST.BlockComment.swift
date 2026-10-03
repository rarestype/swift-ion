internal import Grammar

extension AST {
    /// Matches a block comment: `/* ... */`, supporting nesting.
    enum BlockComment<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> Void
            where Source.Element == Terminal, Source.Index == Location {
            try input.parse(as: Prefix.self)
            var depth: Int = 1
            while depth > 0 {
                guard let byte: UInt8 = input.next() else {
                    throw .unexpectedEndOfInput
                }
                if byte == 0x2F, input.next() == 0x2A {
                    depth += 1
                } else if byte == 0x2A, input.next() == 0x2F {
                    depth -= 1
                }
            }
        }
    }
}
