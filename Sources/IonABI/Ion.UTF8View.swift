extension Ion {
    /// An Ion UTF-8 string.
    ///
    /// This type should not contain potentially-invalid UTF-8 data, but it is not eagerly
    /// validated in order to permit efficient traversal. Thus, it is not backed by a native
    /// Swift ``String``.
    ///
    /// To convert a UTF-8 string to a native Swift ``String`` (repairing potentially invalid
    /// UTF-8), use the ``validated`` property.
    @frozen public struct UTF8View<Bytes>
        where Bytes: BidirectionalCollection<UInt8> {
        /// The UTF-8 code units backing this string.
        public let bytes: Bytes

        @inlinable public init(bytes: Bytes) {
            self.bytes = bytes
        }
    }
}
extension Ion.UTF8View where Bytes: RangeReplaceableCollection {
    @inlinable static var empty: Self { .init(bytes: .init()) }
}
extension Ion.UTF8View: Sendable where Bytes: Sendable {}
extension Ion.UTF8View: Equatable {
    /// Performs a unicode-aware string comparison on two UTF-8 strings.
    @inlinable public static func == (
        a: borrowing Self,
        b: borrowing Ion.UTF8View<some BidirectionalCollection<UInt8>>
    ) -> Bool {
        a.validated == b.validated
    }
}
extension Ion.UTF8View {
    /// Copies and validates the backing storage of the given UTF-8 string to a
    /// native Swift string, repairing invalid code units if needed.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public var validated: String {
        .init(decoding: self.bytes, as: Unicode.UTF8.self)
    }
}
extension Ion.UTF8View /* : CustomStringConvertible */ {
    /// Copies and validates the backing storage of the given UTF-8 string to a
    /// native Swift string, repairing invalid code units if needed.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public var description: String { self.validated }
}
extension Ion.UTF8View {
    public typealias NullGroup = String
}
extension Ion.UTF8View: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: .string, size: self.bytes.count]
        ion.output.append(self.bytes)
    }
}
extension Ion.UTF8View<ArraySlice<UInt8>>: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast { $0.string }
    }
}
