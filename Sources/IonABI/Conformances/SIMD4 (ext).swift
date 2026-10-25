/// A `SIMD4` encodes as a list of its 4 components, in order.
extension SIMD4: IonEncodable, IonEncodableList where Scalar: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.ListEncoder) {
        ion[+] = self.x
        ion[+] = self.y
        ion[+] = self.z
        ion[+] = self.w
    }
}
extension SIMD4: IonDecodable, IonDecodableList where Scalar: IonDecodable {
    @inlinable public init(ion: inout Ion.ListDecoder) throws {
        let x: Scalar = try ion[+].decode(to: Scalar.self)
        let y: Scalar = try ion[+].decode(to: Scalar.self)
        let z: Scalar = try ion[+].decode(to: Scalar.self)
        let w: Scalar = try ion[+].decode(to: Scalar.self)
        if  case _? = try ion[+]?.decode(to: Ion.AnyValue.self) {
            throw Ion.ListLengthError.init(expected: 4)
        }
        self.init(x, y, z, w)
    }
}
