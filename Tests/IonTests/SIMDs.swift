import IonABI
import Testing

@Suite struct SIMDs {
    @Test static func Roundtrips() throws {
        let a: SIMD2<Int> = .init(13, -89)
        let b: SIMD3<Double> = .init(0.5, -1.25, 5.8023393817123834e-06)
        let c: SIMD4<UInt8> = .init(1, 2, 3, 255)

        #expect(try Ion.encode(atomic: a).decode(atomic: SIMD2<Int>.self) == a)
        #expect(try Ion.encode(atomic: b).decode(atomic: SIMD3<Double>.self) == b)
        #expect(try Ion.encode(atomic: c).decode(atomic: SIMD4<UInt8>.self) == c)
    }

    /// A vector encodes exactly as an array of its components does, so that code that stored
    /// either one can read the other.
    @Test static func SameAsArrays() throws {
        let vector: SIMD3<Double> = .init(1.73, 1.70, 1.65)
        let array: [Double] = [1.73, 1.70, 1.65]
        #expect(Ion.encode(atomic: vector).bytes == Ion.encode(atomic: array).bytes)
        #expect(try Ion.encode(atomic: array).decode(atomic: SIMD3<Double>.self) == vector)
    }

    @Test static func TooShort() {
        let ion: Ion = .encode(atomic: [1, 2] as [Int])
        #expect(throws: (any Error).self) {
            try ion.decode(atomic: SIMD3<Int>.self)
        }
    }

    /// A list with an element left over fails on that element, even when it is a null.
    @Test static func TooLong() throws {
        let lists: [Ion] = [
            .encode(atomic: [1, 2, 3, 4] as [Int]),
            .encode(atomic: [1, 2, 3, nil] as [Int?]),
        ]
        for ion: Ion in lists {
            let error: any Error = try #require(throws: (any Error).self) {
                try ion.decode(atomic: SIMD3<Int>.self)
            }
            #expect("\(error)".hasPrefix("ion decoding error in \\.3:"))
        }
    }
}
