extension Double: IonEncodable {
    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        if  self == 0, case .plus = self.sign {
            ion.output[type: .float, size: 0]
        } else if let self: Float = .init(exactly: self) {
            ion.output[type: .float, size: 4]
            ion.output.write(whole: self.bitPattern)
        } else {
            ion.output[type: .float, size: 8]
            ion.output.write(whole: self.bitPattern)
        }
    }
}
extension Double: IonDecodable {
    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        self = try ion.value.cast {
            switch $0 {
            case .float(.float32(let float)?):
                return .init(float)
            case .float(.float64(let double)?):
                return double
            case .int(let sign, let magnitude?):
                guard
                let magnitude: UInt64 = .init(exactly: magnitude),
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
