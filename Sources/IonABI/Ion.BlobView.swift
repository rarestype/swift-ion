extension Ion {
    /// An Ion binary blob.
    @frozen public struct BlobView<Bytes, Group>
        where Bytes: BidirectionalCollection<UInt8>, Group: BlobGroup {
        public let bytes: Bytes

        @inlinable public init(bytes: Bytes) {
            self.bytes = bytes
        }
    }
}
extension Ion.BlobView where Bytes: RangeReplaceableCollection {
    @inlinable static var empty: Self { .init(bytes: .init()) }
}
extension Ion.BlobView: Sendable where Bytes: Sendable {}
extension Ion.BlobView: Equatable {
    /// Returns true if both blobs contains the exact same binary data.
    @inlinable public static func == (
        a: borrowing Self,
        b: borrowing Ion.BlobView<some BidirectionalCollection<UInt8>, Group>
    ) -> Bool {
        a.bytes.elementsEqual(b.bytes)
    }
}
extension Ion.BlobView {
    public typealias NullGroup = Ion.BlobType
}
extension Ion.BlobView: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: Group.type, size: self.bytes.count]
        ion.output.append(self.bytes)
    }
}
extension Ion.BlobView: IonDecodable where Bytes == ArraySlice<UInt8> {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: Group.cast(_:))
    }
}
