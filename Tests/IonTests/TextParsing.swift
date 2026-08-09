import Testing
import IonABI
@testable import IonText

@Suite struct TextParsing {
    @Test(arguments: [true, false]) static func Booleans(_ value: Bool) throws {
        let ion: Ion = .encode(atomic: AST.Node.init(value: .bool(value)))
        #expect(try ion.decode(atomic: Bool.self) == value)
    }
}
