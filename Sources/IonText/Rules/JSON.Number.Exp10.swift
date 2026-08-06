extension JSON.Number {
    /// A namespace for decimal-related functionality.
    enum Exp10 {}
}
extension JSON.Number.Exp10 {
    static var startIndex: Int { 0 }
    static var endIndex: Int { 20 }

    static subscript(power: Int) -> UInt64 {
        switch power {
        case 0: 1
        case 1: 10
        case 2: 100
        case 3: 1_000
        case 4: 10_000
        case 5: 100_000
        case 6: 1_000_000
        case 7: 10_000_000
        case 8: 100_000_000
        case 9: 1_000_000_000
        case 10: 10_000_000_000
        case 11: 100_000_000_000
        case 12: 1_000_000_000_000
        case 13: 10_000_000_000_000
        case 14: 100_000_000_000_000
        case 15: 1_000_000_000_000_000
        case 16: 10_000_000_000_000_000
        case 17: 100_000_000_000_000_000
        case 18: 1_000_000_000_000_000_000
        case 19: 10_000_000_000_000_000_000
        default: fatalError("power out of representable range")
        //  UInt64.max:
        //  18_446_744_073_709_551_615
        }
    }
}
