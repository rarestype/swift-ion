internal import Grammar

extension AST.BlockComment {
    enum Suffix {}
}
extension AST.BlockComment.Suffix: LiteralRule {
    typealias Terminal = UInt8
    static var literal: [UInt8] { [0x2A, 0x2F] }
}
