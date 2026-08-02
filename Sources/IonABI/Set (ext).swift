extension Set: IonEncodable, IonEncodableList where Element: IonEncodable {}
extension Set: IonDecodable, IonDecodableList where Element: IonDecodable {
    @inlinable public init(ion: inout Ion.ListDecoder) throws {
        self.init()
        // important to explicitly specify type, otherwise `Element?.self` will be inferred
        while let next: Element = try ion[+]?.decode(to: Element.self) {
            self.insert(next)
        }
    }
}
