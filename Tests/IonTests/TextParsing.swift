import Testing
import IonABI
import IonText

@Suite struct TextParsing {
    @Test(arguments: [true, false]) static func Booleans(_ value: Bool) throws {
        let ion: Ion = try .parse(atomic: "\(value)")
        #expect(try ion.decode(atomic: Bool.self) == value)
    }
}
