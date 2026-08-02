import Testing
import IonABI

@Suite struct IntegerOverflow {
    @Test static func PositiveOverflow() throws {
        let value: Int64 = 1000
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<(Ion.Sign, Ion.Magnitude), Int8>.self) {
            _ = try ion.decode(atomic: Int8.self)
        }
        #expect(throws: Ion.ValueError<(Ion.Sign, Ion.Magnitude), UInt8>.self) {
            _ = try ion.decode(atomic: UInt8.self)
        }
    }

    @Test static func NegativeOverflow() throws {
        let value: Int64 = -50
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<(Ion.Sign, Ion.Magnitude), UInt64>.self) {
            _ = try ion.decode(atomic: UInt64.self)
        }
        #expect(throws: Ion.ValueError<(Ion.Sign, Ion.Magnitude), UInt128>.self) {
            _ = try ion.decode(atomic: UInt128.self)
        }
    }
}
