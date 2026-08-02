extension String: IonEncodableString, IonDecodableString {}
extension String: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .string }
}
