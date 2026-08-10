import IonABI

extension Ion {
    enum InvalidNumberError: Error, Equatable, Sendable {
        case unsupported(String)
    }
}
extension Ion.InvalidNumberError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unsupported(let string): "unsupported numeric literal '\(string)'"
        }
    }
}
