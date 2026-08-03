public protocol IonEncodableString: IonEncodable {
    override associatedtype NullGroup: Ion.NullGroup = String
}
extension IonEncodableString where Self: StringProtocol {
    // ``StringProtocol`` implies ``CustomStringConvertible``, so this default implementation
    // will be preferred in overload resolution for ``String``.
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.output[type: .string, size: self.utf8.count]
        ion.output.append(self.utf8)
    }
}
extension IonEncodableString where Self: CustomStringConvertible {
    /// Encodes the ``CustomStringConvertible/description`` of this instance as an Ion UTF-8
    /// string.
    ///
    /// This default implementation is provided on an extension on a
    /// dedicated protocol rather than an extension on ``IonEncodable``
    /// itself to prevent unexpected behavior for types (such as ``Double``)
    /// who implement ``LosslessStringConvertible``, but expect to be
    /// encoded as something besides a UTF-8 string.
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        self.description.encode(to: &ion)
    }
}
