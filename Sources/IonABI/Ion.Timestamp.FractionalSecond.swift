extension Ion.Timestamp {
    @frozen public struct FractionalSecond {
        public let exponent: Int
        public var coefficient: Ion.Coefficient?

        @inlinable init(exponent: Int, coefficient: Ion.Coefficient? = nil) {
            self.exponent = exponent
            self.coefficient = coefficient
        }
    }
}
