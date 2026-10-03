internal import Grammar

extension AST.BlockComment {
    enum Prefix {}
}
extension AST.BlockComment.Prefix: LiteralRule {
    typealias Terminal = UInt8
    static var literal: [UInt8] { [0x2F, 0x2A] }
}
