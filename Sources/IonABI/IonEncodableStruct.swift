public protocol IonEncodableStruct<CodingKey>: IonEncodable where NullGroup == Ion.Struct {
    associatedtype CodingKey: IonSymbolizable
    func encode(to ion: inout Ion.StructEncoder<CodingKey>)
}
extension IonEncodableStruct {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.bind(with: self.encode(to:))
    }
}
