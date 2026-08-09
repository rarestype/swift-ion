extension Ion {
    @frozen public enum Magnitude {
        case uint64(UInt64)
        case uint128(UInt128)
        case arbitrary(Words)
    }
}
