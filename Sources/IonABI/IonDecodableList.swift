public protocol IonDecodableList: IonDecodable where NullGroup == Ion.List {
    init(ion: inout Ion.ListDecoder) throws
}
extension IonDecodableList {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.bind(with: Self.init(ion:))
    }
}
extension IonDecodableList where Self: RangeReplaceableCollection, Element: IonDecodable {
    @inlinable public init(ion: inout Ion.ListDecoder) throws {
        self.init()
        // important to explicitly specify type, otherwise `Element?.self` will be inferred
        while let next: Element = try ion[+]?.decode(to: Element.self) {
            self.append(next)
        }
    }
}
