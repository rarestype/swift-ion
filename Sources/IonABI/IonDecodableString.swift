public protocol IonDecodableString: IonDecodable {
    override associatedtype NullGroup: Ion.NullGroup = String
}
extension IonDecodableString where Self: LosslessStringConvertible {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        let view: Ion.UTF8View<ArraySlice<UInt8>> = try ion.value.cast { $0.string }
        let string: String = view.validated
        if  let value: Self = .init(string) {
            self = value
        } else {
            throw Ion.ValueError<String, Self>.init(invalid: string)
        }
    }
}
