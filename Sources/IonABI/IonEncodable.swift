public protocol IonEncodable: ~Copyable {
    associatedtype NullGroup: Ion.NullGroup = Ion.AnyType
    func encode(to ion: inout Ion.NodeEncoder)
}
extension IonEncodable where Self: RawRepresentable, RawValue: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        self.rawValue.encode(to: &ion)
    }
}
extension IonEncodable where Self: BinaryFloatingPoint {
    public typealias NullGroup = Ion.FloatRepresentation
}
extension IonEncodable where Self: BinaryInteger {
    public typealias NullGroup = Ion.IntegerRepresentation
}
extension IonEncodable where Self: FixedWidthInteger {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        guard self != .zero else {
            ion.output[type: .int(.positive), size: 0]
            return
        }

        let magnitude: Magnitude = self.magnitude
        let size: Int = magnitude.bytesSpanned

        if  self < .zero {
            ion.output[type: .int(.negative), size: size]
        } else {
            ion.output[type: .int(.positive), size: size]
        }

        ion.output.write(fixed: magnitude, octets: size)
    }
}
