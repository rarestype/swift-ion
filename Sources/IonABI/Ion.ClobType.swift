extension Ion {
    @frozen public enum ClobType {}
}
extension Ion.ClobType: Ion.BlobGroup {
    @inlinable public static var type: Ion.AnyType { .clob }
    @inlinable public static func cast(
        _ value: consuming Ion.AnyValue
    ) -> Ion.BlobView<ArraySlice<UInt8>, Self>?? { value.clob }
}
