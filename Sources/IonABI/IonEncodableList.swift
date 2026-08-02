public protocol IonEncodableList: IonEncodable where NullGroup == Ion.List {
    func encode(to ion: inout Ion.ListEncoder)
}
extension IonEncodableList {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.bind(with: self.encode(to:))
    }
}
extension IonEncodableList where Self: Sequence, Element: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.ListEncoder) {
        for element: Element in self {
            element.encode(to: &ion[with: +])
        }
    }
}
