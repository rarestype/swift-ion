internal import Grammar
import IonABI

extension AST {
    /// Matches a long string literal (`"""..."""`), including concatenation
    /// of adjacent long string fragments.
    ///
    /// Long strings allow unescaped `"` and `""` inside; only `"""` terminates.
    /// A backslash immediately before a newline acts as a line continuation,
    /// producing no output.
    enum LongString<Location>: ParsingRule {
        typealias Terminal = UInt8
        typealias Construction = String

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws(PatternMatchingError) -> String
            where Source.Element == Terminal, Source.Index == Location {
            var result: String = ""
            try parseFragment(&input, into: &result)
            while true {
                let saved: Location = input.index
                input.parse(as: WhitespaceRule<Location>.self, in: Void.self)
                if input.parse(as: TripleQuote?.self) != nil {
                    try parseFragment(&input, into: &result, openingConsumed: true)
                } else {
                    input.index = saved
                    break
                }
            }
            return result
        }

        private static func peekTripleQuote<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) -> Bool
            where Source.Element == Terminal, Source.Index == Location {
            let saved: Location = input.index
            if input.next() == 0x22, input.next() == 0x22, input.next() == 0x22 {
                return true
            }
            input.index = saved
            return false
        }

        private static func parseFragment<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>,
            into result: inout String,
            openingConsumed: Bool = false
        ) throws(PatternMatchingError)
            where Source.Element == Terminal, Source.Index == Location {
            if !openingConsumed {
                try input.parse(as: TripleQuote.self)
            }
            while true {
                let start: Location = input.index
                input.parse(as: CodeUnit.self, in: Void.self)
                let end: Location = input.index
                if end > start {
                    result += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
                }
                if peekTripleQuote(&input) {
                    return
                }
                let byte: UInt8? = input.next()
                if byte == 0x5C {
                    let beforeEscape: Location = input.index
                    if let next: UInt8 = input.next() {
                        if next == 0x0A { continue }
                        if next == 0x0D {
                            if input.next() == 0x0A { }
                            continue
                        }
                    }
                    input.index = beforeEscape
                    result += try input.parse(as: EscapeSequence.self)
                } else if byte == 0x22 {
                    result += "\""
                } else if end == start {
                    throw .unexpectedValue
                }
            }
        }
    }
}
