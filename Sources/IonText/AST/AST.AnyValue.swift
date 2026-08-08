import IonABI

extension AST {
    enum AnyValue: Sendable {
        case null(Ion.AnyType)
        case bool(Bool)
        case int(Ion.Sign, Ion.Magnitude)
        case float(Ion.FloatRepresentation)
        case decimal(Ion.DecimalRepresentation)
        case timestamp(Ion.Timestamp)
        case symbol(Symbol)
        case string(String)
        case clob([UInt8])
        case blob([UInt8])
        case list([Node])
        case sexp([Node])
        case `struct`([(key: Symbol, value: Node)])
    }
}
