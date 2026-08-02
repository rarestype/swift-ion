import Ion
internal import Bijection

extension Roundtripping {
    enum EnumStringEncoding: Int8, CaseIterable {
        case foobie = 0
        case barbie = 1
    }
}
extension Roundtripping.EnumStringEncoding: IonEncodableString, IonDecodableString {}
extension Roundtripping.EnumStringEncoding: LosslessStringConvertible {
    @Bijection var description: String {
        switch self {
        case .foobie: "foobie"
        case .barbie: "barbie"
        }
    }
}
