extension Ion {
    public protocol NullGroup {
        static var null: Ion.AnyType { get }
        static func inhabits(null: Ion.AnyType) -> Bool
    }
}
extension Ion.NullGroup {
    @inlinable public static func inhabits(null type: Ion.AnyType) -> Bool {
        switch type {
        case self.null: true
        case .null: true
        default: false
        }
    }
}
