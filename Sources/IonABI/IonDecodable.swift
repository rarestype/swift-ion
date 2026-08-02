public protocol IonDecodable: ~Copyable {
    associatedtype NullGroup: Ion.NullGroup = Ion.AnyType
    init(ion: borrowing Ion.NodeDecoder) throws
}
extension IonDecodable where Self: RawRepresentable, RawValue: IonDecodable & Sendable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        let rawValue: RawValue = try .init(ion: ion)
        if  let typed: Self = .init(rawValue: rawValue) {
            self = typed
        } else {
            throw Ion.ValueError<RawValue, Self>.init(invalid: rawValue)
        }
    }
}
extension IonDecodable where Self: BinaryFloatingPoint {
    public typealias NullGroup = Ion.FloatRepresentation
}
extension IonDecodable where Self: BinaryInteger {
    public typealias NullGroup = Ion.Magnitude
}
extension IonDecodable where Self: FixedWidthInteger {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast { try $0.as(Self.self) }
    }
}
