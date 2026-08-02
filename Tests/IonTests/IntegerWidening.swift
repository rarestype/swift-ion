import Ion
import Testing

@Suite struct IntegerWidening {
    @Test(
        arguments: [Int32.min, -256, -1, 0, 1, 256]
    ) static func Floats(_ value: Int32) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Float.self) == Float.init(value))
    }
    @Test(
        arguments: [Int64.min, -256, -1, 0, 1, 256]
    ) static func Doubles(_ value: Int64) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Double.self) == Double.init(value))
    }

    @Test(
        arguments: [Int32.min + 1, Int32.max]
    ) static func FloatRejection(_ value: Int32) throws {
        let sign: Ion.Sign = value < 0 ? .negative : .positive
        let ion: Ion = .encode(atomic: value)
        #expect(throws: Ion.TypecastError<Float>.init(invalid: .int(sign))) {
            try ion.decode(atomic: Float.self)
        }
    }

    @Test(
        arguments: [Int64.min + 1, Int64.max]
    ) static func DoubleRejection(_ value: Int64) throws {
        let sign: Ion.Sign = value < 0 ? .negative : .positive
        let ion: Ion = .encode(atomic: value)
        #expect(throws: Ion.TypecastError<Double>.init(invalid: .int(sign))) {
            try ion.decode(atomic: Double.self)
        }
    }
}
