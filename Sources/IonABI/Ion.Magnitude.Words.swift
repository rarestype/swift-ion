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
    @usableFromInline func load<T>(into _: T.Type = T.self) -> T where T: UnsignedInteger {
        /// todo: benchmark zero-init and big-endian memory copy
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
