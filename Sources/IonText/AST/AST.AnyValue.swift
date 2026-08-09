import IonABI

extension AST {
    enum AnyValue {
        case null(Ion.AnyType)
        case bool(Bool)
        case int(Ion.Sign, Ion.Magnitude)
        case float(Ion.FloatRepresentation)
        case decimal(Ion.DecimalRepresentation)
        case timestamp(Ion.Timestamp)
        case symbol(Symbol)
        case string(String)
        case clob(Ion.BlobView<[UInt8], Ion.ClobType>?)
        case blob(Ion.BlobView<[UInt8], Ion.BlobType>?)
        case list(List)
        case sexp(Sexp)
        case `struct`(Struct)
    }
}
extension AST.AnyValue: IonEncodable {
    func encode(to ion: inout Ion.NodeEncoder) {
        switch self {
        case .null(let self):
            Ion.AnyValue.null(type: self).encode(to: &ion)

        case .bool(let self):
            self.encode(to: &ion)

        case .int(let sign, let magnitude):
            Ion.IntegerRepresentation.init(sign: sign, magnitude: magnitude).encode(to: &ion)

        case .float(let self):
            self.encode(to: &ion)

        case .decimal(let self):
            self.encode(to: &ion)

        case .timestamp(let self):
            self.encode(to: &ion)

        case .symbol(.preassigned(let self)):
            self.encode(to: &ion)

        case .symbol(.name(let self)):
            ion.symbol[self].encode(to: &ion)

        case .string(let self):
            self.encode(to: &ion)

        case .clob(let self):
            self.encode(to: &ion)

        case .blob(let self):
            self.encode(to: &ion)

        case .list(let self):
            self.encode(to: &ion)

        case .sexp(let self):
            self.encode(to: &ion)

        case .struct(let self):
            self.encode(to: &ion)
        }
    }
}
