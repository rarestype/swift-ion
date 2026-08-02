internal import Bijection

extension Ion {
    @frozen public enum AnyType: Equatable, Hashable, Sendable {
        case null
        case bool
        case int(Sign)
        case float
        case decimal
        case timestamp
        case symbol
        case string
        case clob
        case blob
        case list
        case sexp
        case `struct`
    }
}
extension Ion.AnyType: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool { a.code < b.code }
}
extension Ion.AnyType {
    @Bijection(label: "code") @inlinable public var code: UInt8 {
        switch self {
        case .null: 0x00
        case .bool: 0x10
        case .int(.positive): 0x20
        case .int(.negative): 0x30
        case .float: 0x40
        case .decimal: 0x50
        case .timestamp: 0x60
        case .symbol: 0x70
        case .string: 0x80
        case .clob: 0x90
        case .blob: 0xA0
        case .list: 0xB0
        case .sexp: 0xC0
        case .struct: 0xD0
        }
    }
}
extension Ion.AnyType {
    @inlinable public init(code: UInt8) throws(Ion.TypeError) {
        if  let type: Self = .init(code: code) {
            self = type
        } else {
            throw Ion.TypeError.init(invalid: code)
        }
    }
}
extension Ion.AnyType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null: "null"
        case .bool: "bool"
        case .int(.positive): "int(+)"
        case .int(.negative): "int(-)"
        case .float: "float"
        case .decimal: "decimal"
        case .timestamp: "timestamp"
        case .symbol: "symbol"
        case .string: "string"
        case .clob: "clob"
        case .blob: "blob"
        case .list: "list"
        case .sexp: "sexp"
        case .struct: "struct"
        }
    }
}
extension Ion.AnyType: Ion.NullGroup {
    @inlinable public static func inhabits(null _: Ion.AnyType) -> Bool { true }
}
