extension Ion {
    @frozen public struct IntegerRepresentation {
        public let sign: Sign
        public let magnitude: Magnitude

        @inlinable public init(sign: Sign, magnitude: Magnitude) {
            self.sign = sign
            self.magnitude = magnitude
        }
    }
}
extension Ion.IntegerRepresentation {
    public typealias NullGroup = Self
}
extension Ion.IntegerRepresentation: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        switch self.magnitude {
        case .uint64(0):
            ion.output[type: .int(self.sign), size: 0]

        case .uint64(let magnitude):
            let size: Int = magnitude.bytesSpanned
            ion.output[type: .int(self.sign), size: size]
            ion.output.write(fixed: magnitude, octets: size)

        case .uint128(0):
            ion.output[type: .int(self.sign), size: 0]

        case .uint128(let magnitude):
            let size: Int = magnitude.bytesSpanned
            ion.output[type: .int(self.sign), size: size]
            ion.output.write(fixed: magnitude, octets: size)

        case .arbitrary(let words):
            if  words.bytes.allSatisfy({ $0 == 0 }) {
                ion.output[type: .int(self.sign), size: 0]
            } else {
                ion.output[type: .int(self.sign), size: words.bytes.count]
                ion.output.append(words.bytes)
            }
        }
    }
}
extension Ion.IntegerRepresentation: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast {
            guard case .int(let sign, let magnitude?) = $0 else {
                return nil
            }
            return .init(sign: sign, magnitude: magnitude)
        }
    }
}
extension Ion.IntegerRepresentation: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .int(.positive) }
    @inlinable public static func inhabits(null: Ion.AnyType) -> Bool {
        switch null {
        case .null: true
        case .int: true
        default: false
        }
    }
}
