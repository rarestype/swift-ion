import Testing
import IonABI

@Suite struct Roundtripping {
    @Test static func BigIntZero() throws {
        let words: Ion.Magnitude.Words = [
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ]
        let ion: Ion = .encode(atomic: Ion.AnyValue.int(.positive, .arbitrary(words)))
        #expect(try ion.decode(atomic: Int.self) == 0)
    }

    @Test(
        arguments: [.negative, .positive] as [Ion.Sign]
    ) static func BigIntSmall(_ sign: Ion.Sign) throws {
        let words: Ion.Magnitude.Words = [
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
        ]
        let ion: Ion = .encode(atomic: Ion.AnyValue.int(sign, .arbitrary(words)))
        #expect(try ion.decode(atomic: Int.self) == (sign == .positive ? 1 : -1))
    }

    @Test(
        arguments: [.negative, .positive] as [Ion.Sign]
    ) static func BigIntLarge(_ sign: Ion.Sign) throws {
        let words: Ion.Magnitude.Words = [
            0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
        ]
        let ion: Ion = .encode(atomic: Ion.AnyValue.int(sign, .arbitrary(words)))
        let value: Ion.AnyValue = try ion.decode()

        let int: (Ion.Sign, Ion.Magnitude.Words)?
        switch value.int {
        case (let sign, .arbitrary(let words)?)?:
            int = (sign, words)
        default:
            int = nil
        }

        let (sign, decoded): (Ion.Sign, Ion.Magnitude.Words) = try #require(int)

        #expect((sign, decoded) == (sign, words))
    }

    @Test(
        arguments: [
            (.negative, Int.min),
            (.negative, -256),
            (.negative, -1),
            (.negative, 0),
            (.negative, 1),
            (.negative, 255),
            (.negative, Int.max),

            (.positive, Int.min),
            (.positive, -256),
            (.positive, -1),
            (.positive, 0),
            (.positive, 1),
            (.positive, 255),
            (.positive, Int.max)
        ] as [(Ion.Sign, Int)]
    ) static func DecimalLarge(_ sign: Ion.Sign, _ exponent: Int) throws {
        let sign: UInt8 = sign == .negative ? 0x81 : 0x01
        let words: Ion.Coefficient.Words = [
            sign, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
        ]
        let ion: Ion = .encode(atomic: Ion.AnyValue.decimal(.arbitrary(words), e: exponent))
        let value: Ion.AnyValue = try ion.decode()

        let decimal: (Ion.Coefficient.Words, e: Int)?
        if  case let value?? = value.decimal,
            case .arbitrary(let words) = value.coefficient {
            decimal = (words, e: value.exponent)
        } else {
            decimal = nil
        }

        let decoded: (Ion.Coefficient.Words, e: Int) = try #require(decimal)

        #expect(decoded == (words, e: exponent))
    }

    @Test(arguments: [-128, -89, 0, 89, 127]) static func MachineInt(int: Int) throws {
        let ion: Ion = .encode(atomic: int)

        #expect(try ion.decode(atomic: Int.self) == Int.init(int))
        #expect(try ion.decode(atomic: Int8.self) == Int8.init(int))
        #expect(try ion.decode(atomic: Int16.self) == Int16.init(int))
        #expect(try ion.decode(atomic: Int32.self) == Int32.init(int))
        #expect(try ion.decode(atomic: Int64.self) == Int64.init(int))
        #expect(try ion.decode(atomic: Int128.self) == Int128.init(int))

        if  int < 0 {
            return
        }

        #expect(try ion.decode(atomic: UInt.self) == UInt.init(int))
        #expect(try ion.decode(atomic: UInt8.self) == UInt8.init(int))
        #expect(try ion.decode(atomic: UInt16.self) == UInt16.init(int))
        #expect(try ion.decode(atomic: UInt32.self) == UInt32.init(int))
        #expect(try ion.decode(atomic: UInt64.self) == UInt64.init(int))
        #expect(try ion.decode(atomic: UInt128.self) == UInt128.init(int))
    }

    @Test static func MachineIntUnsigned() throws {
        let min8: Ion = .encode(atomic: UInt8.min)
        #expect(try min8.decode(atomic: UInt8.self) == UInt8.min)
        let max8: Ion = .encode(atomic: UInt8.max)
        #expect(try max8.decode(atomic: UInt8.self) == UInt8.max)
        let min16: Ion = .encode(atomic: UInt16.min)
        #expect(try min16.decode(atomic: UInt16.self) == UInt16.min)
        let max16: Ion = .encode(atomic: UInt16.max)
        #expect(try max16.decode(atomic: UInt16.self) == UInt16.max)
        let min32: Ion = .encode(atomic: UInt32.min)
        #expect(try min32.decode(atomic: UInt32.self) == UInt32.min)
        let max32: Ion = .encode(atomic: UInt32.max)
        #expect(try max32.decode(atomic: UInt32.self) == UInt32.max)
        let min64: Ion = .encode(atomic: UInt64.min)
        #expect(try min64.decode(atomic: UInt64.self) == UInt64.min)
        let max64: Ion = .encode(atomic: UInt64.max)
        #expect(try max64.decode(atomic: UInt64.self) == UInt64.max)
        let min128: Ion = .encode(atomic: UInt128.min)
        #expect(try min128.decode(atomic: UInt128.self) == UInt128.min)
        let max128: Ion = .encode(atomic: UInt128.max)
        #expect(try max128.decode(atomic: UInt128.self) == UInt128.max)
    }

    @Test static func MachineIntUnsignedOptional() throws {
        let min8: Ion = .encode(atomic: UInt8.min as UInt8?)
        #expect(try min8.decode(atomic: UInt8.self) == UInt8.min)

        let nil8: Ion = .encode(atomic: nil as UInt8?)
        #expect(try nil8.decode(atomic: UInt8?.self) == nil)

        let max8: Ion = .encode(atomic: UInt8.max as UInt8?)
        #expect(try max8.decode(atomic: UInt8.self) == UInt8.max)


        let min16: Ion = .encode(atomic: UInt16.min as UInt16?)
        #expect(try min16.decode(atomic: UInt16.self) == UInt16.min)

        let nil16: Ion = .encode(atomic: nil as UInt16?)
        #expect(try nil16.decode(atomic: UInt16?.self) == nil)

        let max16: Ion = .encode(atomic: UInt16.max as UInt16?)
        #expect(try max16.decode(atomic: UInt16.self) == UInt16.max)


        let min32: Ion = .encode(atomic: UInt32.min as UInt32?)
        #expect(try min32.decode(atomic: UInt32.self) == UInt32.min)

        let nil32: Ion = .encode(atomic: nil as UInt32?)
        #expect(try nil32.decode(atomic: UInt32?.self) == nil)

        let max32: Ion = .encode(atomic: UInt32.max as UInt32?)
        #expect(try max32.decode(atomic: UInt32.self) == UInt32.max)


        let min64: Ion = .encode(atomic: UInt64.min as UInt64?)
        #expect(try min64.decode(atomic: UInt64.self) == UInt64.min)

        let nil64: Ion = .encode(atomic: nil as UInt64?)
        #expect(try nil64.decode(atomic: UInt64?.self) == nil)

        let max64: Ion = .encode(atomic: UInt64.max as UInt64?)
        #expect(try max64.decode(atomic: UInt64.self) == UInt64.max)


        let min128: Ion = .encode(atomic: UInt128.min as UInt128?)
        #expect(try min128.decode(atomic: UInt128.self) == UInt128.min)

        let nil128: Ion = .encode(atomic: nil as UInt128?)
        #expect(try nil128.decode(atomic: UInt128?.self) == nil)

        let max128: Ion = .encode(atomic: UInt128.max as UInt128?)
        #expect(try max128.decode(atomic: UInt128.self) == UInt128.max)
    }

    @Test static func MachineIntSignedOptional() throws {
        let min8: Ion = .encode(atomic: Int8.min as Int8?)
        #expect(try min8.decode(atomic: Int8.self) == Int8.min)

        let nil8: Ion = .encode(atomic: nil as Int8?)
        #expect(try nil8.decode(atomic: Int8?.self) == nil)

        let max8: Ion = .encode(atomic: Int8.max as Int8?)
        #expect(try max8.decode(atomic: Int8.self) == Int8.max)


        let min16: Ion = .encode(atomic: Int16.min as Int16?)
        #expect(try min16.decode(atomic: Int16.self) == Int16.min)

        let nil16: Ion = .encode(atomic: nil as Int16?)
        #expect(try nil16.decode(atomic: Int16?.self) == nil)

        let max16: Ion = .encode(atomic: Int16.max as Int16?)
        #expect(try max16.decode(atomic: Int16.self) == Int16.max)


        let min32: Ion = .encode(atomic: Int32.min as Int32?)
        #expect(try min32.decode(atomic: Int32.self) == Int32.min)

        let nil32: Ion = .encode(atomic: nil as Int32?)
        #expect(try nil32.decode(atomic: Int32?.self) == nil)

        let max32: Ion = .encode(atomic: Int32.max as Int32?)
        #expect(try max32.decode(atomic: Int32.self) == Int32.max)


        let min64: Ion = .encode(atomic: Int64.min as Int64?)
        #expect(try min64.decode(atomic: Int64.self) == Int64.min)

        let nil64: Ion = .encode(atomic: nil as Int64?)
        #expect(try nil64.decode(atomic: Int64?.self) == nil)

        let max64: Ion = .encode(atomic: Int64.max as Int64?)
        #expect(try max64.decode(atomic: Int64.self) == Int64.max)


        let min128: Ion = .encode(atomic: Int128.min as Int128?)
        #expect(try min128.decode(atomic: Int128.self) == Int128.min)

        let nil128: Ion = .encode(atomic: nil as Int128?)
        #expect(try nil128.decode(atomic: Int128?.self) == nil)

        let max128: Ion = .encode(atomic: Int128.max as Int128?)
        #expect(try max128.decode(atomic: Int128.self) == Int128.max)
    }

    @Test(
        arguments: [
            0, 1, 127, 128, 255, 256, 32767, 32768, 65535, 65536,
            -1, -127, -128, -255, -256, -32767, -32768, -65535, -65536
        ] as [Int64]
    ) static func MachineIntBoundaryTransitions(_ value: Int64) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Int64.self) == value)
        #expect(try ion.decode(atomic: Int64?.self) == value)
    }

    @Test(arguments: [true, false]) static func Booleans(_ value: Bool) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Bool.self) == value)
        #expect(try ion.decode(atomic: Bool?.self) == value)
    }

    @Test(
        arguments: ["", "Hi Barbie", "¡Hola Barbie!", "\u{0}", "🏳️‍⚧️"]
    ) static func Strings(_ value: String) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: String.self) == value)
        #expect(try ion.decode(atomic: String?.self) == value)
    }

    @Test(
        arguments: [" ", "H", "♥", "\u{0}", "🇵🇸"] as [Character]
    ) static func StringsAsCharacter(_ value: Character) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Character.self) == value)
        #expect(try ion.decode(atomic: Character?.self) == value)
    }

    @Test(
        arguments: [" ", "H", "♥", "\u{0}"] as [Unicode.Scalar]
    ) static func StringsAsCodepoint(_ value: Unicode.Scalar) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Unicode.Scalar.self) == value)
        #expect(try ion.decode(atomic: Unicode.Scalar?.self) == value)
    }

    @Test(
        arguments: Enum.allCases
    ) static func StringsAsEnum(_ value: Enum) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Enum.self) == value)
        #expect(try ion.decode(atomic: Enum?.self) == value)
    }

    @Test static func StringsAsEnumOptionalNil() throws {
        let ion: Ion = .encode(atomic: nil as Enum?)
        #expect(try ion.decode(atomic: Enum?.self) == nil)
    }

    @Test(
        arguments: EnumStringEncoding.allCases
    ) static func StringsAsEnumByLosslessStringConvertible(
        _ value: EnumStringEncoding
    ) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: EnumStringEncoding.self) == value)
        #expect(try ion.decode(atomic: EnumStringEncoding?.self) == value)
    }

    @Test static func StringsAsEnumByLosslessStringConvertibleOptionalNil() throws {
        let ion: Ion = .encode(atomic: nil as EnumStringEncoding?)
        #expect(try ion.decode(atomic: EnumStringEncoding?.self) == nil)
    }

    @Test(
        arguments: [
            [],
            [10, 20, 30, 40],
            [_].init(50 ... 999),
        ] as [[Int]]
    ) static func Lists(_ value: [Int]) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: [Int].self) == value)
    }

    @Test(
        arguments: [0, 100, -100]
    ) static func Integers(_ value: Int) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Int.self) == value)
    }

    @Test(
        arguments: EnumRawEncoding.allCases
    ) static func IntegersAsEnum(_ value: EnumRawEncoding) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: EnumRawEncoding.self) == value)
        #expect(try ion.decode(atomic: EnumRawEncoding?.self) == value)
    }

    @Test static func IntegersAsEnumOptionalNil() throws {
        let ion: Ion = .encode(atomic: nil as EnumRawEncoding?)
        #expect(try ion.decode(atomic: EnumRawEncoding?.self) == nil)
    }

    @Test(
        arguments: [3.14159, -0.0, Float.pi]
    ) static func Floats(_ value: Float) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Float.self) == value)
    }

    @Test(
        arguments: [3.14159, -0.0, Double.pi, Double.init(Float.pi)]
    ) static func Doubles(_ value: Double) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Double.self) == value)
    }

    @Test(
        arguments: [.init(x: 89, y: 99), .init(x: -10, y: 20)] as [Struct.Point]
    ) static func Structs(_ value: Struct.Point) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Struct.Point.self) == value)
    }

    @Test(
        arguments: [.init(x: 89, y: 99), nil, .init(x: -10, y: 20)] as [Struct.Point?]
    ) static func StructsOptional(_ value: Struct.Point?) throws {
        let ion: Ion = .encode(atomic: value)
        #expect(try ion.decode(atomic: Struct.Point?.self) == value)
    }

    @Test static func StructsNested() throws {
        let record: Struct = .init(
            label: "Origin",
            point: .init(x: 100, y: 200),
            tag: "checkpoint"
        )
        let ion: Ion = .encode(atomic: record)
        let decoded: Struct = try ion.decode()
        #expect(decoded == record)
    }

    @Test static func StructNestedOptionalNil() throws {
        let record: Struct = .init(
            label: "NullTag",
            point: .init(x: 5, y: 15),
            tag: nil
        )
        let ion: Ion = .encode(atomic: record)
        let decoded: Struct = try ion.decode()
        #expect(decoded == record)
        #expect(decoded.tag == nil)
    }

    @Test(
        arguments: [
            (Int16.min, 2026),
            (-300, 2026),
            (0, 2026),
            (nil, 2026),
            (300, 2026),
            (Int16.max, 2026),
        ] as [(Int16?, UInt16)]
    ) static func Timestamps(offset: Int16?, year: UInt16) throws {
        let date: Ion.Timestamp = .init(offset: offset, year: year)
        let time: Ion.Timestamp = .init(offset: offset, year: year) {
            $0[2][14][9, 59][58][e: 1].coefficient = .int64(2)
        }

        do {
            let ion: Ion = .encode(atomic: date)
            let decoded: Ion.Timestamp = try ion.decode(atomic: Ion.Timestamp.self)

            #expect(decoded.offset == offset)
            #expect(decoded.year == year)
        }
        do {
            let ion: Ion = .encode(atomic: time)
            let decoded: Ion.Timestamp = try ion.decode(atomic: Ion.Timestamp.self)

            #expect(decoded.offset == offset)
            #expect(decoded.year == year)
            #expect(decoded[0].month == 2)
            #expect(decoded[0][0].day == 14)
            #expect(decoded[0][0][0, 0].time == (9, 59, 58))
            #expect(decoded[0][0][0, 0][0][e: 0].exponent == 1)

            let coefficient: Int64?
            if  case .int64(let int64)? = decoded[0][0][0, 0][0][e: 0].coefficient {
                coefficient = int64
            } else {
                coefficient = nil
            }
            #expect(coefficient == 2)
        }
    }

    @Test static func NullGroupInference() {
        /// unfortunately we cannot supply `typealias NullGroup = RawValue.NullGroup`, it just
        /// breaks everything...
        let _: Ion.AnyType.Type = Enum.NullGroup.self
        let _: Ion.AnyType.Type = EnumRawEncoding.NullGroup.self

        let _: IonCodable<String>.NullGroup.Type = EnumStringEncoding.NullGroup.self
        let _: IonCodable<Ion.Struct>.NullGroup.Type = Struct.Point.NullGroup.self
        let _: IonCodable<Ion.Struct>.NullGroup.Type = Struct.NullGroup.self
    }
}
