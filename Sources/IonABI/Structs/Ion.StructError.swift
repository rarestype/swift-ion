extension Ion {
    enum StructError: Error {
        case duplicate(Symbol.ID)
    }
}
extension Ion.StructError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .duplicate(let id): "duplicate field id (\(id))"
        }
    }
}
