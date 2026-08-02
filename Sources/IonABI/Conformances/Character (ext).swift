extension Character: IonEncodableString {}
extension Character: IonDecodableString {
    /// Witnesses `Character`’s ``IonDecodableString`` conformance, throwing
    /// a ``Ion.ValueError`` instead of trapping on multi-character input.
    ///
    /// This is needed because its ``LosslessStringConvertible.init(_:)``
    /// witness traps on invalid input instead of returning nil, which causes
    /// its default implementation (where `Self` is ``LosslessStringConvertible``)
    /// to do the same.
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        let view: Ion.UTF8View<ArraySlice<UInt8>> = try ion.value.cast { $0.string }
        let string: String = view.validated
        if  string.startIndex < string.endIndex,
            string.index(after: string.startIndex) == string.endIndex {
            self = string[string.startIndex]
        } else {
            throw Ion.ValueError<String, Self>.init(invalid: string)
        }
    }
}
