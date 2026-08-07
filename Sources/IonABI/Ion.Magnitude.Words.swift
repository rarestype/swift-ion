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
    @inlinable public func load<T>(
        into _: T.Type = T.self
    ) -> T where T: UnsignedInteger & FixedWidthInteger {
        return self.bytes.withUnsafeBytes {
            guard
            let first: UnsafeRawPointer = $0.baseAddress, !$0.isEmpty else {
                return .zero
            }
            let bytes: Int = $0.count

            let length: Int
            let offset: Int
            let source: UnsafeRawPointer

            let target: Int = MemoryLayout<T>.size
            if  target > bytes {
                // source buffer is smaller than the target, pad with zeroes
                length = bytes
                offset = target - bytes
                source = first
            } else {
                // source buffer is larger than the target, truncate
                // (caller is responsible for bounds checking)
                length = target
                offset = 0
                source = first.advanced(by: bytes - target)
            }

            var bigEndian: T = .zero

            withUnsafeMutableBytes(of: &bigEndian) {
                $0.baseAddress!.advanced(by: offset).copyMemory(from: source, byteCount: length)
            }

            return T.init(bigEndian: bigEndian)
        }
    }
}
