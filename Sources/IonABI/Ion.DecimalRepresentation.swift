extension Ion {
    @frozen public struct DecimalRepresentation {
        public let exponent: Int
        public let coefficient: Coefficient

        @inlinable public init(
            _ coefficient: Coefficient,
            e exponent: Int,
        ) {
            self.exponent = exponent
            self.coefficient = coefficient
        }
    }
}
extension Ion.DecimalRepresentation {
    static func parse(from input: inout Ion.Input) throws(Ion.InputError) -> Self {
        try .init(from: &input)
    }

    private init(from input: inout Ion.Input) throws(Ion.InputError) {
        let exponent: Int = try input.parse()
        self.init(try .init(from: &input), e: exponent)
    }
}
extension Ion.DecimalRepresentation {
    private var bytesRequired: Int {
        if  let coefficient: Int = self.coefficient.bytesRequired {
            self.exponent.magnitude.bytesRequiredWithSign + coefficient
        } else {
            self.exponent.magnitude.bytesRequiredWithSign
        }
    }

    @usableFromInline static func += (output: inout Ion.Output, self: Self) {
        let size: Int = self.bytesRequired

        output[type: .decimal, size: size]
        output.reserve(another: size)

        output.write(variable: self.exponent, allocate: false)
        output += self.coefficient
    }
}
extension Ion.DecimalRepresentation {
    public typealias NullGroup = Self
}
extension Ion.DecimalRepresentation: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) { ion.output += self }
}
extension Ion.DecimalRepresentation: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast(with: \.decimal)
    }
}
extension Ion.DecimalRepresentation: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .decimal }
}
