import Ion
internal import Bijection

extension Roundtripping {
    enum EnumRawEncoding: Int8, IonEncodable, IonDecodable, CaseIterable {
        case foobie = 0
        case barbie = 1
    }
}
extension Roundtripping.EnumRawEncoding: LosslessStringConvertible {
    @Bijection var description: String {
        switch self {
        case .foobie: "foobie"
        case .barbie: "barbie"
        }
    }
}
