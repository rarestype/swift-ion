extension Optional where Wrapped: ~Copyable {
    @inlinable subscript(default default: () -> Wrapped) -> Wrapped {
        _read {
            switch self {
            case let self?:
                yield self
            case nil:
                yield `default`()
            }
        }
        _modify {
            var value: Wrapped? = self.take()
            defer { self = value.take() }

            if  value != nil {
                yield &value!
            } else {
                var new: Wrapped = `default`()
                yield &new
                value = consume new
            }
        }
    }
}
extension Optional: IonEncodable where Wrapped: IonEncodable {
    public typealias NullGroup = Wrapped.NullGroup

    @inlinable public func encode(to ion: inout Ion.NodeEncoder) {
        switch self {
        case nil: ion.output[null: NullGroup.null]
        case let self?: self.encode(to: &ion)
        }
    }
}
extension Optional: IonDecodable where Wrapped: IonDecodable {
    public typealias NullGroup = Wrapped.NullGroup

    @inlinable public init(ion: borrowing Ion.NodeDecoder) throws {
        if  let null: Ion.AnyType = ion.value.null, NullGroup.inhabits(null: null) {
            self = nil
        } else {
            self = try Wrapped.init(ion: ion)
        }
    }
}
