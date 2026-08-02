import Testing
import Ion

extension Roundtripping {
    struct Struct: Equatable {
        let label: String
        let point: Point
        let tag: String?

        init(label: String, point: Point, tag: String? = nil) {
            self.label = label
            self.point = point
            self.tag = tag
        }
    }
}
extension Roundtripping.Struct {
    enum CodingKey: String, IonSymbolizable {
        case label
        case point
        case tag
    }
}
extension Roundtripping.Struct: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.label] = self.label
        ion[.point] = self.point
        ion[.tag] = self.tag
    }
}
extension Roundtripping.Struct: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.label = try ion[.label]?.decode() ?? ""
        self.point = try ion[.point].decode()
        self.tag = try ion[.tag]?.decode()
    }
}
