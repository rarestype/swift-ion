extension Ion {
    @frozen public enum FieldAccessError<ID>: Error where ID: Sendable {
        /// A struct did not contain a field with the expected identifier.
        case undefined(ID)
    }
}
extension Ion.FieldAccessError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undefined(let key):
            """
            required field '\(key)' is missing from struct \
            (keyed by type '\(String.init(reflecting: ID.self))')
            """
        }
    }
}
