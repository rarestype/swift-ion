extension Ion {
    @frozen public struct List: Sendable {
        public let bytes: ArraySlice<UInt8>

        /// Creates an empty list.
        @inlinable public init() {
            self.bytes = []
        }
        /// Bind an opaque buffer to a list.
        @inlinable public init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Ion.List {
    public typealias NullGroup = Self
}
extension Ion.List: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: .list, size: self.bytes.count]
        ion.output.append(self.bytes)
    }
}
extension Ion.List: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.list)
    }
}
extension Ion.List: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .list }
}
extension Ion.List {
    @inlinable var values: Iterator { .init(input: .init(self.bytes)) }
}
