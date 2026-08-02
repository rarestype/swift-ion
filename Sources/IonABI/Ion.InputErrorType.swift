extension Ion {
    @frozen @usableFromInline enum InputErrorType {
        case arbitrary(any Error)
        /// The `remaining` field is the number of bytes remaining in the input.
        case expected(InputError.Expectation, remaining: Int)
        /// The Ion version marker (IVM) is invalid.
        case invalidIVM((UInt8, UInt8, UInt8))
        /// The type description marker (TDM) is invalid.
        case invalidTDM(t: AnyType, l: Int)
    }
}
