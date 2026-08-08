extension AST.Number {
    enum Exp10 {}
}
extension AST.Number.Exp10 {
    static var endIndex: Int { 20 }

    static subscript(index: Int) -> UInt64 {
        switch index {
        case 0: 1
        case 1: 10
        case 2: 100
        case 3: 1000
        case 4: 10000
        case 5: 100000
        case 6: 1000000
        case 7: 10000000
        case 8: 100000000
        case 9: 1000000000
        case 10: 10000000000
        case 11: 100000000000
        case 12: 1000000000000
        case 13: 10000000000000
        case 14: 100000000000000
        case 15: 1000000000000000
        case 16: 10000000000000000
        case 17: 100000000000000000
        case 18: 1000000000000000000
        case 19: 10000000000000000000
        default: fatalError("Exp10 index out of bounds")
        }
    }
}
