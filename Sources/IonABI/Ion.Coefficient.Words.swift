extension Ion.Coefficient {
    @frozen public struct Words: Equatable, Sendable {
        @usableFromInline let bytes: ArraySlice<UInt8>
        @inlinable public init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Ion.Coefficient.Words: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral: UInt8...) {
        self.init(bytes: arrayLiteral[...])
    }
}
extension Ion.Coefficient.Words: RandomAccessCollection {
    @inlinable public var startIndex: Int { 0 }
    @inlinable public var endIndex: Int { self.bytes.count }
    @inlinable public subscript(offset: Int) -> UInt8 {
        self.bytes[self.bytes.index(self.bytes.startIndex, offsetBy: offset)]
    }
}
extension Ion.Coefficient.Words {
    @inlinable public func load<T>(
        into _: T.Type = T.self
    ) -> (negative: Bool, magnitude: T) where T: UnsignedInteger {
        // ion signed int uses signed-magnitude, not two’s complement
        var i: Int = self.bytes.startIndex
        let first: UInt8 = self.bytes[i]
        var value: T = T.init(first & 0b0111_1111)
        while true {
            i = self.bytes.index(after: i)

            guard i < self.bytes.endIndex else {
                return (negative: first & 0b1000_0000 != 0, value)
            }

            value = T.init(self.bytes[i]) | value << 8
        }
    }
}
