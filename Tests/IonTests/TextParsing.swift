import Testing
import IonABI
import IonText

@Suite struct TextParsing {
    @Test(arguments: [true, false]) static func Booleans(_ value: Bool) throws {
        let ion: Ion = try .parse(atomic: "\(value)")
        #expect(try ion.decode(atomic: Bool.self) == value)
    }

    @Test(
        arguments: [
            (0, "0"),
            (1, "1"),
            (42, "42"),
            (-1, "-1"),
            (-100, "-100"),
            (500, "+500"),
            (9223372036854775807, "9223372036854775807"),
            (-9223372036854775808, "-9223372036854775808"),
        ] as [(Int, String)]
    ) static func IntegersBase10(_ expected: Int, _ text: String) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Int.self) == expected)
    }

    @Test(
        arguments: [
            (0x0, "0x0"),
            (0x1f, "0x1f"),
            (0x1F, "0x1F"),
            (-0xfe, "-0xfe"),
            (0xAB, "+0xAB"),
            (0x7fffffffffffffff, "0x7fffffffffffffff"),
        ] as [(Int, String)]
    ) static func IntegersBase16(_ expected: Int, _ text: String) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Int.self) == expected)
    }

    @Test(
        arguments: [
            (0b0, "0b0"),
            (0b1, "0b1"),
            (0b1010, "0b1010"),
            (-0b1111, "-0b1111"),
            (0b1100, "+0b1100"),
            (0b11111111, "0b11111111"),
        ] as [(Int, String)]
    ) static func IntegersBase2(_ expected: Int, _ text: String) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Int.self) == expected)
    }

    @Test(
        arguments: [
            (1000000, "1_000_000"),
            (-1234567, "-1_234_567"),
            (0x12abcd, "0x12_ab_cd"),
            (0b10100101, "0b1010_0101"),
        ] as [(Int, String)]
    ) static func IntegersUnderscored(_ expected: Int, _ text: String) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Int.self) == expected)
    }

    @Test(
        arguments: [
            (0.0, "0.0e0"),
            (12300.0, "1.23e4"),
            (-0.0015, "-1.5e-3"),
            (10000000000.0, "+1.0e10"),
            (0.00001, "1.0E-5"),
        ] as [(Double, String)]
    ) static func FloatsBase10(_ expected: Double, _ text: String) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Double.self) == expected)
    }

    @Test static func FloatsNaN() throws {
        let ion: Ion = try .parse(atomic: "nan")
        let value: Double = try ion.decode(atomic: Double.self)
        #expect(value.isNaN)
    }

    @Test(
        arguments: [
            ("+inf", Double.infinity),
            ("-inf", -Double.infinity),
        ] as [(String, Double)]
    ) static func FloatsInfinity(_ text: String, _ expected: Double) throws {
        let ion: Ion = try .parse(atomic: text)
        #expect(try ion.decode(atomic: Double.self) == expected)
    }

    // @Test(
    //     arguments: [
    //         ("0.0", 0, -1),
    //         ("1.23", 123, -2),
    //         ("-12.345", -12345, -3),
    //         ("0d0", 0, 0),
    //         ("1d-5", 1, -5),
    //     ] as [(String, Int64, Int)]
    // ) static func DecimalsBase10(_ text: String, _ expectedCoeff: Int64, _ expectedExp: Int) throws {
    //     let ion: Ion = try .parse(atomic: text)
    //     let value: Ion.AnyValue = try ion.decode()
    //     guard case let decimal?? = value.decimal else {
    //         Issue.record("Expected decimal value")
    //         return
    //     }
    //     #expect(decimal.exponent == expectedExp)
    //     if case .int64(let coeff) = decimal.coefficient {
    //         #expect(coeff == expectedCoeff)
    //     } else {
    //         Issue.record("Expected .int64 coefficient")
    //     }
    // }
}
