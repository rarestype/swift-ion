internal import Grammar

extension AST.AnnotationRule {
    enum DoubleColon: LiteralRule {
        typealias Terminal = UInt8
        static var literal: [UInt8] { [0x3A, 0x3A] }
    }
}
