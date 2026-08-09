public protocol IonEncodableSexp: IonEncodable where NullGroup == Ion.Sexp {
    func encode(to ion: inout Ion.ListEncoder)
}
extension IonEncodableSexp {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        ion.bind(to: Ion.SexpEncoder.self) { self.encode(to: &$0.list) }
    }
}
