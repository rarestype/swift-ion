extension Float: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        if  self == 0, case .plus = self.sign {
            ion.output[type: .float, size: 0]
        } else {
            ion.output[type: .float, size: 4]
            ion.output.write(whole: self.bitPattern)
        }
    }
}
extension Float: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast {
            switch $0 {
            case .float(.float32(let float)?):
                return float
            case .float(.float64(let double)?):
                return Self.init(exactly: double)
            case .int(let sign, let magnitude?):
                guard
                let magnitude: UInt32 = .init(exactly: magnitude),
                var value: Self = .init(exactly: magnitude) else {
                    return nil
                }
                if  case .negative = sign {
                    value.negate()
                }
                return value

            default:
                return nil
            }
        }
    }
}
