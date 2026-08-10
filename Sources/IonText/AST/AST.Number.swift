import IonABI

extension AST {
    enum Number {
        case int(Ion.Sign, Ion.Magnitude)
        case float(Ion.FloatRepresentation)
        case decimal(Ion.DecimalRepresentation)
        case unrepresentable(String)
    }
}
