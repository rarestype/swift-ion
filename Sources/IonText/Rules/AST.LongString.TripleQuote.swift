internal import Grammar

extension AST.LongString {
    enum TripleQuote: LiteralRule {
        typealias Terminal = UInt8
        static var literal: [UInt8] { [0x22, 0x22, 0x22] }
    }
}
