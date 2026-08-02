import Ion

extension Roundtripping.Struct {
    struct Point: Equatable {
        let x: Int
        let y: Int

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
}
extension Roundtripping.Struct.Point {
    enum CodingKey: String, IonSymbolizable {
        case x
        case y
    }
}
extension Roundtripping.Struct.Point: IonEncodableStruct {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.x] = self.x
        ion[.y] = self.y
    }
}
extension Roundtripping.Struct.Point: IonDecodableStruct {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.x = try ion[.x]?.decode() ?? 0
        self.y = try ion[.y]?.decode() ?? 0
    }
}
