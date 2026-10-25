/// A `SIMD2` encodes as a list of its 2 components, in order.
extension SIMD2: IonEncodable, IonEncodableList where Scalar: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.ListEncoder) {
        ion[+] = self.x
        ion[+] = self.y
    }
}
extension SIMD2: IonDecodable, IonDecodableList where Scalar: IonDecodable {
    @inlinable public init(ion: inout Ion.ListDecoder) throws {
        let x: Scalar = try ion[+].decode(to: Scalar.self)
        let y: Scalar = try ion[+].decode(to: Scalar.self)
        if  case _? = try ion[+]?.decode(to: Ion.AnyValue.self) {
            throw Ion.ListLengthError.init(expected: 2)
        }
        self.init(x, y)
    }
}
