internal import Grammar

extension AST.TypedNull {
    enum NullPrefix {}
}
extension AST.TypedNull.NullPrefix: LiteralRule {
    typealias Terminal = UInt8
    static var literal: [UInt8] { [0x6e, 0x75, 0x6c, 0x6c] }
}
