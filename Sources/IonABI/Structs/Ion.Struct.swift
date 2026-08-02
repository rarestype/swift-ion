extension Ion {
    @frozen public struct Struct: Sendable {
        public let bytes: ArraySlice<UInt8>

        /// Creates an empty struct.
        @inlinable public init() {
            self.bytes = []
        }
        /// Bind an opaque buffer to a struct.
        @inlinable public init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Ion.Struct {
    public typealias NullGroup = Self
}
extension Ion.Struct: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: .struct, size: self.bytes.count]
        ion.output.append(self.bytes)
    }
}
extension Ion.Struct: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.struct)
    }
}
extension Ion.Struct: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .struct }
}
extension Ion.Struct {
    @inlinable var fields: Iterator { .init(input: .init(self.bytes)) }

    @usableFromInline var parsed: [Ion.Symbol.ID: Ion.Node] {
        get throws {
            var fields: Ion.Struct.Iterator = self.fields
            var index: [Ion.Symbol.ID: Ion.Node] = [:]

            while let (key, node): (Ion.Symbol.ID, Ion.Node?) = try fields.next() {
                guard let node: Ion.Node else {
                    // skip no-op padding
                    continue
                }
                guard case nil = index.updateValue(node, forKey: key) else {
                    throw Ion.StructError.duplicate(key)
                }
            }
            return index
        }
    }
}
