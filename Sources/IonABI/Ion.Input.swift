extension Ion {
    @frozen public struct Input: Sendable {
        @usableFromInline let bytes: ArraySlice<UInt8>
        @usableFromInline var index: Int

        @inlinable init(bytes: ArraySlice<UInt8>, index: Int) {
            self.bytes = bytes
            self.index = index
        }
    }
}
extension Ion.Input {
    @inlinable public init(_ source: ArraySlice<UInt8>) {
        self.init(bytes: source, index: source.startIndex)
    }
}
extension Ion.Input {
    public mutating func parseOuter() throws(Ion.InputError) -> Ion.TopLevelNode? {
        repeat {
            switch try self.marker() {
            case .header(let header):
                guard let node: Ion.Node = try self.parse(with: header) else {
                    // skip all no-op padding
                    continue
                }
                return .node(node)
            case .v1_0:
                return .v1_0
            }
        } while !self.exhausted
        return nil
    }

    mutating func parseInner() throws(Ion.InputError) -> Ion.Node? {
        repeat {
            let header: Ion.Header = try self.header()
            // skip all no-op padding
            if  let node: Ion.Node = try self.parse(with: header) {
                return node
            }
        } while !self.exhausted
        return nil
    }
}
extension Ion.Input {
    var exhausted: Bool { self.index == self.bytes.endIndex }
    var remaining: Int {
        self.bytes.distance(from: self.index, to: self.bytes.endIndex)
    }

    private func index(advanced octets: Int) throws(Ion.InputError) -> Int {
        guard
        let end: Int = self.bytes.index(
            self.index,
            offsetBy: octets,
            limitedBy: self.bytes.endIndex
        ) else {
            throw self.expected(.bytes(octets))
        }

        return end
    }

    /// Creates an ``InputError`` with appropriate context for the specified expectation.
    private func expected(
        _ what: Ion.InputError.Expectation,
    ) -> Ion.InputError {
        .expected(what, remaining: self.remaining)
    }
}
extension Ion.Input {
    private mutating func skip(_ octets: Int) throws(Ion.InputError) {
        self.index = try self.index(advanced: octets)
    }

    /// Consumes and returns a single byte from this parsing input.
    private mutating func next() -> UInt8? {
        guard self.index < self.bytes.endIndex else {
            return nil
        }
        defer {
            self.bytes.formIndex(after: &self.index)
        }

        return self.bytes[self.index]
    }

    private mutating func next() throws(Ion.InputError) -> UInt8 {
        guard let byte: UInt8 = self.next() else {
            throw .expected(.bytes(1), remaining: 0)
        }
        return byte
    }

    private mutating func next<T>(
        _ octets: Int,
        _ yield: (inout Self) throws(Ion.InputError) -> T
    ) throws(Ion.InputError) -> T  where T: ~Copyable {
        let index: Int = try self.index(advanced: octets)
        var slice: Self = .init(
            bytes: self.bytes[self.index ..< index],
            index: self.index
        )
        self.index = index
        return try yield(&slice)
    }

    mutating func next<T>(
        _ octets: Int,
        _ yield: (ArraySlice<UInt8>) -> T
    ) throws(Ion.InputError) -> T  where T: ~Copyable {
        try self.next(octets) { yield($0.bytes) }
    }
}
extension Ion.Input {
    /// Parse a variable-length unsigned integer.
    private mutating func parse<T>(
        variable _: T.Type = T.self,
        extending value: inout T
    ) throws(Ion.InputError) where T: BinaryInteger {
        while true {
            let byte: UInt8 = try self.next()

            let uint7: UInt8 = byte & 0b0111_1111
            let final: UInt8 = byte & 0b1000_0000

            value = T.init(uint7) | value << 7

            if  final != 0 {
                return
            }
        }
    }

    /// Parse a variable-length unsigned integer.
    mutating func parse<T>(
        variable _: T.Type = T.self
    ) throws(Ion.InputError) -> T where T: UnsignedInteger {
        var value: T = .zero
        try self.parse(extending: &value)
        return value
    }

    /// Parse a variable-length signed integer.
    mutating func parse<T>(
        variable _: T.Type = T.self
    ) throws(Ion.InputError) -> (
        sign: Ion.Sign,
        magnitude: T.Magnitude
    ) where T: SignedInteger {
        let first: UInt8 = try self.next()
        let uint6: UInt8 = first & 0b0011_1111
        let final: UInt8 = first & 0b1000_0000

        var value: T.Magnitude = .init(uint6)
        if  final == 0 {
            try self.parse(extending: &value)
        }

        return (first & 0b0100_0000 == 0 ? .positive : .negative, value)
    }
    /// Parse a variable-length signed integer.
    mutating func parse<T>(
        variable _: T.Type = T.self
    ) throws(Ion.InputError) -> T where T: SignedInteger & FixedWidthInteger {
        let value: (Ion.Sign, T.Magnitude) = try self.parse(variable: T.self)
        guard
        let value: T = .init(exactly: value) else {
            throw self.expected(.inhabitant)
        }
        return value
    }
}
extension Ion.Input {
    private mutating func marker() throws(Ion.InputError) -> Ion.Marker {
        let byte: UInt8 = try self.next()
        if  byte == Ion.Node.Types.mask {
            let marker: (UInt8, UInt8, UInt8) = try self.next(3) {
                let major: Int = $0.startIndex
                let minor: Int = $0.index(after: major)
                let final: Int = $0.index(after: minor)

                return ($0[major], $0[minor], $0[final])
            }

            if  marker == Ion.v1_0 {
                return .v1_0
            } else {
                throw .init(type: .invalidIVM(marker))
            }
        }

        let header: Ion.Header

        let high: UInt8 = byte & 0xf0
        if  high == Ion.Node.Types.mask {
            switch byte & 0x0f {
            case 14:
                header = .typed(size: Int.init(try self.parse(variable: UInt.self)))
            case let L:
                header = .typed(size: Int.init(L))
            }
        } else {
            let type: Ion.AnyType

            do {
                type = try .init(code: high)
            } catch let error {
                throw .arbitrary(error)
            }

            let size: Int?

            switch byte & 0x0f {
            case 15:
                size = nil
            case 14:
                size = Int.init(try self.parse(variable: UInt.self))
            case let L:
                if  case .struct = type,
                    case 1 = L {
                    size = Int.init(try self.parse(variable: UInt.self))
                } else {
                    size = Int.init(L)
                }
            }

            header = .value(size: size, type: type)
        }

        return .header(header)
    }

    mutating func header() throws(Ion.InputError) -> Ion.Header {
        guard case .header(let header) = try self.marker() else {
            throw self.expected(.header)
        }
        return header
    }

    /// Parses a fixed-width unsigned integer. This is generally only useful if the size of the
    /// encoded value already matches the size of a native machine integer type.
    mutating func parse<T>(
        whole _: T.Type,
    ) throws(Ion.InputError) -> T where T: UnsignedInteger & FixedWidthInteger {
        try self.next(MemoryLayout<T>.size) { (bigEndian: ArraySlice<UInt8>) in
            withUnsafeTemporaryAllocation(
                byteCount: MemoryLayout<T>.size,
                alignment: MemoryLayout<T>.alignment,
            ) {
                $0.copyBytes(from: bigEndian)
                return .init(bigEndian: $0.load(as: T.self))
            }
        }
    }

    mutating func parse<T>(
        into _: T.Type = T.self,
        octets: Int
    ) throws(Ion.InputError) -> T where T: UnsignedInteger {
        try self.next(octets) {
            let pattern: Ion.Magnitude.Words = .init(bytes: $0)
            return pattern.load(into: T.self)
        }
    }

    mutating func parse<T>(
        into _: T.Type = T.self,
        octets: Int
    ) throws(Ion.InputError) -> (sign: Ion.Sign, magnitude: T) where T: UnsignedInteger {
        try self.next(octets) {
            let pattern: Ion.Coefficient.Words = .init(bytes: $0)
            return pattern.load(into: T.self)
        }
    }
}
extension Ion.Input {
    private mutating func parse(
        with header: Ion.Header
    ) throws(Ion.InputError) -> Ion.Node? {
        switch header {
        case .value(size: let size, type: let type):
            guard
            let size: Int else {
                return .init(types: nil, value: .null(type: type))
            }
            if  let value: Ion.AnyValue = try self.parse(value: type, size: size) {
                return .init(types: nil, value: value)
            } else {
                // no-op padding
                return nil
            }

        case .typed(size: let size):
            return try self.next(size) { (
                    self: inout Self
                ) throws(Ion.InputError) in
                let subsize: Int = .init(try self.parse(variable: UInt.self))
                let annotations: Ion.Node.Types = try self.next(subsize) { (
                        self: inout Self
                    ) throws(Ion.InputError) in
                    /// there is always at least one annotation
                    var annotations: Ion.Node.Types = .init(
                        first: Ion.Symbol.ID.init(rawValue: try self.parse())
                    )
                    while !self.exhausted {
                        annotations.extra.append(
                            Ion.Symbol.ID.init(rawValue: try self.parse())
                        )
                    }
                    return annotations
                }

                guard case .value(size: let size, type: let type) = try self.header() else {
                    throw self.expected(.value)
                }

                guard let size: Int else {
                    return .init(types: annotations, value: .null(type: type))
                }
                if  let value: Ion.AnyValue = try self.parse(value: type, size: size) {
                    return .init(types: annotations, value: value)
                } else {
                    throw self.expected(.inhabitant)
                }
            }
        }
    }

    private mutating func parse(
        value type: Ion.AnyType,
        size: Int
    ) throws(Ion.InputError) -> Ion.AnyValue? {
        switch type {
        case .null:
            try self.skip(size)
            return nil

        case .bool:
            switch size {
            case 0:
                return .bool(false)
            case 1:
                return .bool(true)
            default:
                throw .invalidTDM(t: type, l: size)
            }

        case .int(let sign):
            let magnitude: Ion.Magnitude

            if  size <= 0 {
                magnitude = .uint64(0)
            } else if size <= 8 {
                magnitude = .uint64(try self.parse(octets: size))
            } else if size <= 16 {
                magnitude = .uint128(try self.parse(octets: size))
            } else {
                magnitude = .arbitrary(try self.next(size) { .init(bytes: $0) })
            }

            return .int(sign, magnitude)

        case .float:
            let float: Ion.FloatRepresentation

            switch size {
            case 0:
                float = .float32(0)
            case 4:
                float = .float32(Float.init(bitPattern: try self.parse(whole: UInt32.self)))
            case 8:
                float = .float64(Double.init(bitPattern: try self.parse(whole: UInt64.self)))
            default:
                throw .invalidTDM(t: type, l: size)
            }

            return .float(float)

        case .decimal:
            return .decimal(try self.next(size, Ion.DecimalRepresentation.parse(from:)))

        case .timestamp:
            return .timestamp(try self.next(size, Ion.Timestamp.parse(from:)))

        case .symbol:
            let symbol: Ion.Symbol.ID

            if  size <= 0 {
                symbol = 0
            } else if size <= MemoryLayout<UInt32>.size {
                symbol = .init(rawValue: try self.parse(octets: size))
            } else {
                throw .invalidTDM(t: type, l: size)
            }

            return .symbol(symbol)

        case .string:
            if  size <= 0 {
                return .string(.empty)
            } else {
                return .string(try self.next(size) { .init(bytes: $0) })
            }

        case .clob:
            if  size <= 0 {
                return .clob(.empty)
            } else {
                return .clob(try self.next(size) { .init(bytes: $0) })
            }

        case .blob:
            if  size <= 0 {
                return .blob(.empty)
            } else {
                return .blob(try self.next(size) { .init(bytes: $0) })
            }

        case .list:
            if  size <= 0 {
                return .list(.init())
            } else {
                return .list(try self.next(size) { .init(bytes: $0) })
            }

        case .sexp:
            if  size <= 0 {
                return .sexp(.init())
            } else {
                return .sexp(try self.next(size) { .init(bytes: $0) })
            }

        case .struct:
            if  size <= 0 {
                return .struct(.init())
            } else {
                return .struct(try self.next(size) { .init(bytes: $0) })
            }
        }
    }
}
