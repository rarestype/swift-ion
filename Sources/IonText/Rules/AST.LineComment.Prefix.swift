internal import Grammar

extension AST.LineComment {
    enum Prefix {}
}
extension AST.LineComment.Prefix: LiteralRule {
    typealias Terminal = UInt8
    static var literal: [UInt8] { [0x2F, 0x2F] }
}
