import Ion

struct Integers<T: Equatable & Sendable>: Equatable, Sendable {
    let values: [T]

    init(values: [T]) {
        self.values = values
    }
}
extension Integers {
    enum CodingKey: String, IonSymbolizable {
        case values
    }
}
extension Integers: IonEncodable, IonEncodableStruct where T: IonEncodable {
    func encode(to ion: inout Ion.StructEncoder<CodingKey>) {
        ion[.values] = self.values
    }
}
extension Integers: IonDecodable, IonDecodableStruct where T: IonDecodable {
    init(ion: borrowing Ion.StructDecoder<CodingKey>) throws {
        self.values = try ion[.values].decode()
    }
}
