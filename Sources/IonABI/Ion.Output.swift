extension Ion {
    @frozen @usableFromInline struct Output: Sendable {
        @usableFromInline var bytes: [UInt8]
        @usableFromInline var holes: [Range<Int>]
        @usableFromInline var holesLength: Int

        /// Create an output with a pre-allocated destination buffer. The buffer
        /// does *not* need to be empty, and existing data will not be cleared.
        @inlinable public init(preallocated bytes: [UInt8]) {
            self.bytes = bytes
            self.holes = []
            self.holesLength = 0
        }

        /// Create an empty output, reserving enough space for the specified
        /// number of bytes in the destination buffer.
        @inlinable public init(capacity: Int) {
            self.bytes = []
            self.bytes.reserveCapacity(capacity)
            self.holes = []
            self.holesLength = 0
        }
    }
}
extension Ion.Output {
    @inlinable consuming func move() -> [UInt8] {
        var buffer: [UInt8] = []
        self.move(into: &buffer)
        return buffer
    }

    @inlinable consuming func move(into buffer: inout [UInt8]) {
        if !self.holes.isEmpty {
            buffer.reserveCapacity(buffer.count + (self.bytes.count - self.holesLength))
            self.holes.sort { $0.lowerBound < $1.lowerBound }

            let first: Int = self.holes.startIndex
            let hole: Range<Int> = self.holes[first]
            if  buffer.isEmpty {
                buffer = [UInt8].init(self.bytes[..<hole.lowerBound])
            } else {
                buffer += self.bytes[..<hole.lowerBound]
            }
            var start: Int = hole.upperBound
            for hole: Range<Int> in self.holes[self.holes.index(after: first)...] {
                buffer += self.bytes[start ..< hole.lowerBound]
                start = hole.upperBound
            }

            if  start < self.bytes.endIndex {
                buffer += self.bytes[start ..< self.bytes.endIndex]
            }
        } else {
            if  buffer.isEmpty {
                buffer = self.bytes
            } else {
                buffer += self.bytes
            }
        }
    }
}
extension Ion.Output {
    @inline(always) @inlinable static var null6: (
        UInt8, UInt8,
        UInt8, UInt8,
        UInt8, UInt8,
    ) { (0, 0, 0, 0, 0, 0) }
}
extension Ion.Output {
    /// Reserves another `bytes` worth of capacity in the output destination, in addition to the
    /// bytes already present.
    @inlinable mutating func reserve(another bytes: Int) {
        self.bytes.reserveCapacity(self.bytes.count + bytes)
    }

    /// Appends a single byte to the output destination.
    @inlinable mutating func append(_ byte: UInt8) {
        self.bytes.append(byte)
    }

    /// Appends a sequence of bytes to the output destination.
    @inlinable mutating func append(_ bytes: some Sequence<UInt8>) {
        self.bytes.append(contentsOf: bytes)
    }

    /// Appends a contiguous raw buffer of bytes to the output destination.
    @inlinable mutating func append(_ bytes: UnsafeRawBufferPointer) {
        self.bytes.append(contentsOf: bytes)
    }

    /// Appends a raw span of bytes to the output destination.
    @inlinable mutating func append(_ bytes: RawSpan) {
        bytes.withUnsafeBytes { self.bytes.append(contentsOf: $0) }
    }
}
extension Ion.Output {
    @inline(always) @inlinable mutating func write<T>(
        variable: T
    ) where T: FixedWidthInteger & SignedInteger {
        let magnitude: T.Magnitude = variable.magnitude
        let size: Int = magnitude.bytesRequiredWithSign

        var sign: Bool = variable < 0
        for j: Int in (0 ..< size).reversed() {
            self.append(magnitude[byte: j, sign: sign])
            sign = false
        }
    }

    @inline(always) @inlinable mutating func write<T>(
        variable: T
    ) where T: FixedWidthInteger & UnsignedInteger {
        let magnitude: T.Magnitude = variable.magnitude
        let size: Int = magnitude.bytesRequired

        for j: Int in (0 ..< size).reversed() {
            self.append(magnitude[byte: j])
        }
    }

    private mutating func write<T>(
        variable: T,
        at index: Int,
    ) -> Int where T: FixedWidthInteger & UnsignedInteger {
        var i: Int = index
        for j: Int in (0 ..< variable.bytesRequired).reversed() {
            self.bytes[i] = variable[byte: j] ; i += 1
        }
        return i
    }
}
extension Ion.Output {
    @inlinable mutating func write(field id: Ion.Symbol.ID) {
        self.write(variable: id.rawValue)
    }

    /// Write the entire bit pattern of the value in big-endian order.
    @inlinable mutating func write(whole value: some FixedWidthInteger) {
        withUnsafeBytes(of: value.bigEndian) { self.append($0) }
    }

    /// Write the low `octets` of the `fixed` value in big-endian order.
    @inlinable mutating func write(
        fixed value: some FixedWidthInteger & UnsignedInteger,
        octets: Int
    ) {
        withUnsafeBytes(of: value.bigEndian) {
            let start: Int = $0.index($0.endIndex, offsetBy: -octets)
            self.append($0[start...])
        }
    }

    /// Write the low `octets` of the `fixed` value in big-endian order. The very first byte
    /// written will have its sign bit set if the value is negative.
    @inlinable mutating func write<Magnitude>(
        fixed value: (negative: Bool, magnitude: Magnitude),
        octets: Int,
    ) where Magnitude: FixedWidthInteger & UnsignedInteger {
        if  value.negative {
            withUnsafeBytes(of: value.magnitude.bigEndian) {
                let start: Int = $0.index($0.endIndex, offsetBy: 1 - octets)
                let first: UInt8
                if  start == $0.startIndex {
                    first = 0b1000_0000
                } else {
                    first = 0b1000_0000 | $0[$0.index(before: start)]
                }
                self.append(first)
                self.append($0[start...])
            }
        } else {
            if  octets > MemoryLayout<Magnitude>.size {
                self.append(0)
                self.write(fixed: value.magnitude, octets: MemoryLayout<Magnitude>.size)
            } else {
                self.write(fixed: value.magnitude, octets: octets)
            }
        }
    }

    /// Writes a struct field with the value set to no-op padding (0).
    @inlinable mutating func write(padding: Int) {
        self.append(repeatElement(0, count: padding))
    }
}
extension Ion.Output {
    @inline(always) @inlinable subscript(bool L: Bool) -> () {
        mutating get {
            self.append(L ? Ion.AnyType.bool.code | 1 : Ion.AnyType.bool.code)
        }
    }

    @inline(always) @inlinable subscript(null type: Ion.AnyType) -> () {
        mutating get {
            self.append(type.code | 15)
        }
    }

    @inline(always) @inlinable subscript(type type: Ion.AnyType, size size: Int) -> () {
        mutating get {
            if  size >= 14 {
                self.append(type.code | 14)
            } else {
                self.append(type.code | UInt8.init(size))
                guard case .struct = type, 1 == size else {
                    return
                }
            }

            self.write(variable: UInt.init(size))
        }
    }

    @inlinable subscript<T>(
        types first: Ion.Symbol.ID,
        _ extra: Ion.Symbol.ID...,
        symbols symbols: [Ion.Symbol]
    ) -> T? where T: IonEncodable {
        get { nil }
        set (value) {
            self[types: .init(first: first, extra: extra), symbols: symbols] = value
        }
    }

    @inlinable subscript<T>(
        types types: Ion.Node.Types,
        symbols symbols: [Ion.Symbol]
    ) -> T? where T: IonEncodable {
        get { nil }
        set (value) {
            guard let value: T else {
                return
            }
            {
                var inner: Ion.NodeEncoder = .init(
                    table: .init(predefined: symbols),
                    output: consume $0
                )
                value.encode(to: &inner)
                $0 = inner.output
            } (&self[types: types])
        }
    }

    @inlinable subscript(types types: Ion.Node.Types) -> Self {
        mutating _read {
            yield self[mask: Ion.Node.Types.mask]
        }
        _modify {
            let header: Int = self.bytes.endIndex

            self.append(Ion.Node.Types.mask)
            withUnsafeBytes(of: Self.null6) { self.append($0) }

            let start: Int = self.bytes.endIndex
            let holes: Int = self.holesLength
            let bytes: Int = self.bytes.count

            var subsize: Int = types.first.rawValue.bytesRequired
            for type: Ion.Symbol.ID in types.extra {
                subsize += type.rawValue.bytesRequired
            }

            self.write(variable: UInt.init(subsize))
            self.write(variable: types.first.rawValue)
            for type: Ion.Symbol.ID in types.extra {
                self.write(variable: type.rawValue)
            }

            defer {
                assert(start <= self.bytes.endIndex)

                let bytes: Int = self.bytes.count - bytes
                let holes: Int = self.holesLength - holes
                self.update(length: bytes - holes, at: header ..< start)
            }

            yield &self
        }
    }

    @inlinable subscript(type type: Ion.AnyType) -> Self {
        mutating _read {
            yield  self[mask: type.code]
        }
        _modify {
            yield &self[mask: type.code]
        }
    }
    @inlinable subscript(mask code: UInt8) -> Self {
        mutating _read {
            self.append(code)
            yield self
        }

        _modify {
            let header: Int = self.bytes.endIndex
            // 4.4 TB ought to be enough for anybody
            self.append(code)
            withUnsafeBytes(of: Self.null6) { self.append($0) }

            let start: Int = self.bytes.endIndex
            let holes: Int = self.holesLength
            let bytes: Int = self.bytes.count

            defer {
                /// Make sure the caller has not cleared the buffer.
                assert(start <= self.bytes.endIndex)

                let bytes: Int = self.bytes.count - bytes
                let holes: Int = self.holesLength - holes
                self.update(length: bytes - holes, at: header ..< start)
            }

            yield &self
        }
    }

    /// Updates the length header at the specified `header` position to contain the given
    /// `length` value, returning the unused space.
    @usableFromInline mutating func update(length: Int, at header: Range<Int>) {
        let base: Int = self.bytes.index(after: header.lowerBound)
        if  length < 14 {
            self.bytes[header.lowerBound] |= UInt8.init(length)
            self.hole(at: base ..< header.upperBound)
            return
        } else {
            self.bytes[header.lowerBound] |= 14
        }

        let ending: Int = self.write(variable: UInt.init(length), at: base)
        if  ending < header.upperBound {
            self.hole(at: ending ..< header.upperBound)
        } else if ending > header.upperBound {
            fatalError("exceeded maximum supported ion container size")
        }
    }

    private mutating func hole(at range: Range<Int>) {
        if  self.bytes.endIndex == range.upperBound {
            self.bytes.removeLast(range.count)
        } else {
            self.holes.append(range)
            self.holesLength += range.count
        }
    }
}
