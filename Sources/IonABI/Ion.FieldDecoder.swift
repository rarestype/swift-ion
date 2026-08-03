extension Ion {
    /// A type that represents a scope for decoding operations.
    public protocol FieldDecoder<ID>: ~Copyable {
        associatedtype ID
        var id: ID { get }
        /// Attempts to load a BSON variant value and passes it to the given
        /// closure, returns its result. If decoding fails, the implementation
        /// should annotate the error with appropriate context and re-throw it.
        func decode<T>(
            with decode: (borrowing NodeDecoder) throws -> T
        ) throws -> T where T: ~Copyable
    }
}
extension Ion.FieldDecoder where Self: ~Copyable {
    @inlinable public func decode<CodingKey, T>(
        using _: CodingKey.Type = CodingKey.self,
        with decode: (borrowing Ion.StructDecoder<CodingKey>) throws -> T
    ) throws -> T where T: ~Copyable {
        try self.decode { try $0.bind(with: decode) }
    }

    @inlinable public func decode<T>(
        with decode: (inout Ion.ListDecoder) throws -> T
    ) throws -> T where T: ~Copyable {
        try self.decode { try $0.bind(with: decode) }
    }

    @inlinable public func decode<Decodable, T>(
        as _: Decodable.Type,
        with decode: (borrowing Decodable) throws -> T
    ) throws -> T where T: ~Copyable, Decodable: ~Copyable & IonDecodable {
        try self.decode { try decode(try .init(ion: $0)) }
    }

    @inlinable public func decode<Decodable>(
        to _: Decodable.Type = Decodable.self
    ) throws -> Decodable where Decodable: ~Copyable & IonDecodable {
        try self.decode(with: Decodable.init(ion:))
    }
}
