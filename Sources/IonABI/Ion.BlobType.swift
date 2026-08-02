extension Ion {
    @frozen public enum BlobType {}
}
extension Ion.BlobType: Ion.BlobGroup {
    @inlinable public static var type: Ion.AnyType { .blob }
    @inlinable public static func cast(
        _ value: consuming Ion.AnyValue
    ) -> Ion.BlobView<ArraySlice<UInt8>, Self>?? { value.blob }
}
