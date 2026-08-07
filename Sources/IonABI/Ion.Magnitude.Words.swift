extension Ion.Magnitude {
    @frozen public struct Words: Equatable, Sendable {
        @usableFromInline let bytes: ArraySlice<UInt8>
        @inlinable public init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Ion.Magnitude.Words: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral: UInt8...) {
        self.init(bytes: arrayLiteral[...])
    }
}
extension Ion.Magnitude.Words: RandomAccessCollection {
    @inlinable public var startIndex: Int { 0 }
    @inlinable public var endIndex: Int { self.bytes.count }
    @inlinable public subscript(offset: Int) -> UInt8 {
        self.bytes[self.bytes.index(self.bytes.startIndex, offsetBy: offset)]
    }
}
extension Ion.Magnitude.Words {
    @inlinable var trimmed: Self { .init(bytes: self.bytes.drop { $0 == 0 }) }
}
extension Ion.Magnitude.Words {
    @inlinable public func load<T>(into _: T.Type = T.self) -> T where T: UnsignedInteger {
        // this is an iterative algorithm that pushes bytes one by one to `T`. it was intended
        // to be used with a custom bigint receiver type, but benchmarks indicate it is also
        // faster than an “optimized” raw memory-copying approach for fixed-width integer types.
        if  self.bytes.isEmpty {
            return .zero
        }
        var i: Int = self.bytes.startIndex
        var value: T = T.init(self.bytes[i])
        while true {
            i = self.bytes.index(after: i)

            guard i < self.bytes.endIndex else {
                return value
            }

            value = T.init(self.bytes[i]) | value << 8
        }
    }
}
