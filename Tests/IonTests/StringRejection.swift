import Testing
import IonABI

@Suite struct CaseRejection {
    @Test(
        arguments: ["", "  ", " \u{0}"]
    ) static func Characters(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<String, Character>.self) {
            try ion.decode(atomic: Character.self)
        }
    }

    @Test(
        arguments: ["", "  ", " \u{0}", "🇵🇸"]
    ) static func Codepoints(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<String, Unicode.Scalar>.self) {
            try ion.decode(atomic: Unicode.Scalar.self)
        }
    }

    @Test(
        arguments: ["", " ", "foo", "🏳️‍⚧️"]
    ) static func Enums(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<String, Roundtripping.Enum>.self) {
            try ion.decode(atomic: Roundtripping.Enum.self)
        }
    }

    @Test(
        arguments: ["", " ", "foo", "🏳️‍🌈"]
    ) static func EnumsRawEncodingTypecast(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.TypecastError<Int8>.self) {
            try ion.decode(atomic: Roundtripping.EnumRawEncoding.self)
        }
    }

    @Test(
        arguments: [-1, 2]
    ) static func EnumsRawEncoding(_ value: Int) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<Int8, Roundtripping.EnumRawEncoding>.self) {
            try ion.decode(atomic: Roundtripping.EnumRawEncoding.self)
        }
    }

    @Test(
        arguments: ["", " ", "foo", "🇨🇺"]
    ) static func EnumsStringEncoding(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.ValueError<String, Roundtripping.EnumStringEncoding>.self) {
            try ion.decode(atomic: Roundtripping.EnumStringEncoding.self)
        }
    }

    @Test(
        arguments: [-1, 2]
    ) static func EnumsStringEncodingTypecast(_ value: Int) throws {
        let ion: Ion = .encode(atomic: value)

        #expect(throws: Ion.TypecastError<Ion.UTF8View<ArraySlice<UInt8>>>.self) {
            try ion.decode(atomic: Roundtripping.EnumStringEncoding.self)
        }
    }
}
