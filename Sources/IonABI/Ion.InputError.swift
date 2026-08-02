extension Ion {
    @frozen public struct InputError: Error {
        @usableFromInline let type: InputErrorType
        @inlinable init(type: InputErrorType) {
            self.type = type
        }
    }
}
extension Ion.InputError {
    @inlinable static func expected(
        _ what: Ion.InputError.Expectation,
        remaining: Int
    ) -> Self {
        .init(type: .expected(what, remaining: remaining))
    }

    @inlinable static func invalidTDM(t: Ion.AnyType, l: Int) -> Self {
        .init(type: .invalidTDM(t: t, l: l))
    }

    @inlinable static func invalidIVM(_ bvm: (UInt8, UInt8, UInt8)) -> Self {
        .init(type: .invalidIVM(bvm))
    }

    @inlinable public static func arbitrary(_ error: consuming any Error) -> Self {
        .init(type: .arbitrary(error))
    }
}
extension Ion.InputError: CustomStringConvertible {
    public var description: String {
        switch self.type {
        case .arbitrary(let error):
            "message parsing error (\(error))"
        case .expected(.bytes(let expected), remaining: let remaining):
            "invalid message size (\(remaining) bytes remaining), expected \(expected) bytes"
        case .expected(.value, remaining: _):
            "message parsing error, type annotation may not wrap another type annotation"
        case .expected(.inhabitant, remaining: _):
            "message parsing error, type annotation may not no-op padding"
        case .expected(let what, remaining: _):
            "message parsing error, expected \(what)"
        case .invalidTDM(t: let t, l: let l):
            "message parsing error, invalid type descriptor (T = \(t), L = \(l))"
        case .invalidIVM((1, 0, let final)):
            "message parsing error, invalid IVM terminator (\(final))"
        case .invalidIVM((let major, let minor, _)):
            "unsupported version (\(major).\(minor))"
        }
    }
}
