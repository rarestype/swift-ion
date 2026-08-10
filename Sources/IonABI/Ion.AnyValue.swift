extension Ion {
    /// A low-level, read-only view of an Ion value.
    /// The wrapped array slices are frequently sliced from the input buffer, but not always.
    /// Therefore, the indices of the slices should not be assumed to correspond to positions
    /// in the original buffer.
    @frozen public enum AnyValue {
        case null
        case bool(Bool?)
        case int(Sign, Magnitude?)
        case float(FloatRepresentation?)
        case decimal(DecimalRepresentation?)
        case timestamp(Timestamp?)
        case symbol(Symbol.ID?)
        case string(UTF8View<ArraySlice<UInt8>>?)
        case clob(BlobView<ArraySlice<UInt8>, Ion.ClobType>?)
        case blob(BlobView<ArraySlice<UInt8>, Ion.BlobType>?)
        case list(List?)
        case sexp(Sexp?)
        case `struct`(Struct?)
    }
}
extension Ion.AnyValue {
    @inlinable public static func decimal(
        _ coefficient: Ion.Coefficient,
        e exponent: Int
    ) -> Self {
        .decimal(.init(coefficient, e: exponent))
    }
}
extension Ion.AnyValue {
    @inlinable public var type: Ion.AnyType {
        switch self {
        case .null: .null
        case .bool: .bool
        case .int(let sign, _): .int(sign)
        case .float: .float
        case .decimal: .decimal
        case .timestamp: .timestamp
        case .symbol: .symbol
        case .string: .string
        case .clob: .clob
        case .blob: .blob
        case .list: .list
        case .sexp: .sexp
        case .struct: .struct
        }
    }

    /// Returns the null type if the value is null, a Swift nil if the Ion value is non-null.
    @inlinable public var null: Ion.AnyType? {
        switch self {
        case .null: .null
        case .bool(nil): .bool
        case .int(let sign, nil): .int(sign)
        case .float(nil): .float
        case .decimal(nil): .decimal
        case .timestamp(nil): .timestamp
        case .symbol(nil): .symbol
        case .string(nil): .string
        case .clob(nil): .clob
        case .blob(nil): .blob
        case .list(nil): .list
        case .sexp(nil): .sexp
        case .struct(nil): .struct
        default: nil
        }
    }

    @inlinable public static func null(type: Ion.AnyType) -> Self {
        switch type {
        case .null: .null
        case .bool: .bool(nil)
        case .int(let sign): .int(sign, nil)
        case .float: .float(nil)
        case .decimal: .decimal(nil)
        case .timestamp: .timestamp(nil)
        case .symbol: .symbol(nil)
        case .string: .string(nil)
        case .clob: .clob(nil)
        case .blob: .blob(nil)
        case .list: .list(nil)
        case .sexp: .sexp(nil)
        case .struct: .struct(nil)
        }
    }
}
extension Ion.AnyValue {
    /// Promotes a nil result to a thrown ``TypecastError``.
    ///
    /// If `T` conforms to ``IonDecodable``, prefer calling its throwing
    /// ``IonDecodable/init(ion:) [requirement]`` to calling this method directly.
    ///
    /// >   Throws: A ``TypecastError`` if the given curried method returns nil.
    @inline(always) @inlinable public func cast<T>(
        with cast: (Self) throws -> T??
    ) throws -> T {
        guard case let value?? = try cast(self) else {
            throw Ion.TypecastError<T>.init(invalid: self.type)
        }

        return value
    }
}
extension Ion.AnyValue {
    /// Attempts to load an instance of some ``FixedWidthInteger`` from this variant.
    ///
    /// -   Returns:
    ///     An integer derived from the payload of this variant
    ///     if it matches ``int(sign:magnitude:)``, and it can be represented exactly by
    ///     `Integer`; nil otherwise.
    ///
    /// The ``decimal(_:)`` and ``float(_:)`` variants will *not* match, even if they encode
    /// integral values.
    ///
    /// This method reports failure in two ways — it returns nil on a type
    /// mismatch, and it throws an ``Ion.ValueError`` if this variant
    /// was an integer, but it could not be represented exactly by `Integer`.
    @inlinable func `as`<Integer>(_: Integer.Type) throws -> Integer??
        where Integer: FixedWidthInteger {
        guard case .int(let sign, let magnitude) = self else {
            return nil
        }
        guard let magnitude: Ion.Magnitude else {
            return nil as Integer?
        }
        if  let integer: Integer = .init(exactly: (sign, magnitude)) {
            return integer
        } else {
            throw Ion.ValueError<(Ion.Sign, Ion.Magnitude), Integer>.init(
                invalid: (sign, magnitude)
            )
        }
    }
}
extension Ion.AnyValue {
    @inlinable public var bool: Bool?? {
        switch self {
        case .bool(let bool): bool
        default: nil
        }
    }
    @inlinable public var int: (Ion.Sign, Ion.Magnitude?)? {
        switch self {
        case .int(let sign, let magnitude): (sign, magnitude)
        default: nil
        }
    }
    @inlinable public var float: Ion.FloatRepresentation?? {
        switch self {
        case .float(let float): float
        default: nil
        }
    }
    @inlinable public var decimal: Ion.DecimalRepresentation?? {
        switch self {
        case .decimal(let decimal): decimal
        default: nil
        }
    }
    @inlinable public var timestamp: Ion.Timestamp?? {
        switch self {
        case .timestamp(let timestamp): timestamp
        default: nil
        }
    }
    @inlinable public var symbol: Ion.Symbol.ID?? {
        switch self {
        case .symbol(let symbol): symbol
        default: nil
        }
    }
    @inlinable public var string: Ion.UTF8View<ArraySlice<UInt8>>?? {
        switch self {
        case .string(let string): string
        default: nil
        }
    }
    @inlinable public var clob: Ion.BlobView<ArraySlice<UInt8>, Ion.ClobType>?? {
        switch self {
        case .clob(let clob): clob
        default: nil
        }
    }
    @inlinable public var blob: Ion.BlobView<ArraySlice<UInt8>, Ion.BlobType>?? {
        switch self {
        case .blob(let blob): blob
        default: nil
        }
    }
    @inlinable public var list: Ion.List?? {
        switch self {
        case .list(let list): list
        default: nil
        }
    }
    @inlinable public var sexp: Ion.Sexp?? {
        switch self {
        case .sexp(let sexp): sexp
        default: nil
        }
    }
    @inlinable public var `struct`: Ion.Struct?? {
        switch self {
        case .struct(let `struct`): `struct`
        default: nil
        }
    }
}
extension Ion.AnyValue {
    public typealias NullGroup = Ion.AnyType
}
extension Ion.AnyValue: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        switch self {
        case .null:
            ion.output[null: .null]

        case .int(let sign, let magnitude):
            let value: Ion.IntegerRepresentation?

            if  let magnitude: Ion.Magnitude {
                value = .init(sign: sign, magnitude: magnitude)
            } else {
                value = nil
            }

            value.encode(to: &ion)

        case .bool(let self): self.encode(to: &ion)
        case .float(let self): self.encode(to: &ion)
        case .decimal(let self): self.encode(to: &ion)
        case .timestamp(let self): self.encode(to: &ion)
        case .symbol(let self): self.encode(to: &ion)
        case .string(let self): self.encode(to: &ion)
        case .clob(let self): self.encode(to: &ion)
        case .blob(let self): self.encode(to: &ion)
        case .list(let self): self.encode(to: &ion)
        case .sexp(let self): self.encode(to: &ion)
        case .struct(let self): self.encode(to: &ion)
        }
    }
}
extension Ion.AnyValue: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) {
        self = ion.value
    }
}
