extension Ion {
    @frozen public struct Sexp: Sendable {
        public let bytes: ArraySlice<UInt8>

        /// Creates an empty symbolic expression.
        @inlinable public init() {
            self.bytes = []
        }
        /// Bind an opaque buffer to a symbolic expression.
        @inlinable public init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Ion.Sexp {
    public typealias NullGroup = Self
}
extension Ion.Sexp: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: .sexp, size: self.bytes.count]
        ion.output.append(self.bytes)
    }
}
extension Ion.Sexp: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.sexp)
    }
}
extension Ion.Sexp: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .sexp }
}
extension Ion.Sexp {
    @inlinable var values: Ion.List.Iterator { .init(input: .init(self.bytes)) }
}
