extension Ion {
    enum Header {
        /// If “`size`” is nil, then the value is a typed null. If `type` is ``AnyType/bool``,
        /// then “`size`” encodes the boolean state, and the actual size is zero.
        case value(size: Int?, type: Ion.AnyType)
        case typed(size: Int)
    }
}
extension Ion.Header {
    /// The number of octets expected in the value following this header.
    var size: Int {
        switch self {
        // important! the physical size of `bool` is always zero!
        case .value(_, type: .bool): 0
        case .value(size: let size, type: _): size ?? 0
        case .typed(size: let size): size
        }
    }
}
