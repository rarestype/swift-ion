/// A `SIMD3` encodes as a list of its 3 components, in order.
extension SIMD3: IonEncodable, IonEncodableList where Scalar: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.ListEncoder) {
        ion[+] = self.x
        ion[+] = self.y
        ion[+] = self.z
    }
}
extension SIMD3: IonDecodable, IonDecodableList where Scalar: IonDecodable {
    @inlinable public init(ion: inout Ion.ListDecoder) throws {
        let x: Scalar = try ion[+].decode(to: Scalar.self)
        let y: Scalar = try ion[+].decode(to: Scalar.self)
        let z: Scalar = try ion[+].decode(to: Scalar.self)
        // a list with more elements than that fails to decode the next one
        _ = try ion[+]?.decode(to: Never.self)
        self.init(x, y, z)
    }
}
