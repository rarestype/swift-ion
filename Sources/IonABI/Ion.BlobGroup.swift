extension Ion {
    public protocol BlobGroup: NullGroup {
        static var type: Ion.AnyType { get }
        static func cast(
            _ value: consuming Ion.AnyValue
        ) -> Ion.BlobView<ArraySlice<UInt8>, Self>??
    }
}
extension Ion.BlobGroup {
    @inlinable public static var null: Ion.AnyType { self.type }
}
