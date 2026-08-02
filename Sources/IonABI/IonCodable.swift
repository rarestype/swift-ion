/// A static helper that allows the type system to disambiguate retrieve the overlapping
/// `NullGroup` and `CodingKey` associated types from a type that conforms to both
/// ``IonEncodable`` and ``IonDecodable``.
///
/// This type exists because the two protocols are totally disjoint, which means attempting to
/// reference the associated types directly on `T` will often fail, due to multiple redundant
/// typealiases to the same type.
@frozen public enum IonCodable<T> where T: IonEncodable & IonDecodable {}
extension IonCodable {
    public typealias NullGroup = T.NullGroup
}
extension IonCodable where T: IonEncodableStruct & IonDecodableStruct {
    public typealias CodingKey = T.CodingKey
}
