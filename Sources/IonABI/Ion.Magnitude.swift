extension Ion {
    @frozen public enum Magnitude {
        case uint64(UInt64)
        case uint128(UInt128)
        case arbitrary(Words)
    }
}
extension Ion.Magnitude: Ion.NullGroup {
    @inlinable public static var null: Ion.AnyType { .int(.positive) }
    @inlinable public static func inhabits(null: Ion.AnyType) -> Bool {
        switch null {
        case .null: true
        case .int: true
        default: false
        }
    }
}
