extension Ion {
    @frozen public struct NodeEncoder: ~Copyable  {
        @usableFromInline var table: SymbolEncoder
        @usableFromInline var output: Output
        @inlinable init(table: consuming SymbolEncoder, output: consuming Output) {
            self.table = table
            self.output = output
        }
    }
}
extension Ion.NodeEncoder {
    @inline(always) @inlinable public var symbol: Ion.SymbolEncoder {
        _read   { yield  self.table }
        _modify { yield &self.table }
    }
}
extension Ion.NodeEncoder {
    @inline(always) @inlinable public mutating func _wrap<T, E>(
        as types: Ion.Node.Types,
        with encode: (inout Self) throws(E) -> T
    ) throws(E) -> T where T: ~Copyable {
        try { (table: inout Ion.SymbolEncoder, output: inout Ion.Output) throws(E) in
            var encoder: Ion.NodeEncoder = .init(table: consume table, output: consume output)
            do throws(E) {
                let value: T = try encode(&encoder)
                output = encoder.output
                table = encoder.table
                return value
            } catch {
                output = encoder.output
                table = encoder.table
                throw error
            }
        } (&self.table, &self.output[types: types])
    }

    @inline(always) @inlinable mutating func bind<T, E, Encoder>(
        to _: Encoder.Type = Encoder.self,
        with encode: (inout Encoder) throws(E) -> T
    ) throws(E) -> T where T: ~Copyable, Encoder: ~Copyable & Ion.Encoder {
        try { (table: inout Ion.SymbolEncoder, output: inout Ion.Output) throws(E) in
            let context: Ion.NodeEncoder
            var encoder: Encoder = .acquire(
                context: .init(table: consume table, output: consume output)
            )
            do throws(E) {
                let value: T = try encode(&encoder)
                context = encoder.release()
                output = context.output
                table = context.table
                return value
            } catch {
                context = encoder.release()
                output = context.output
                table = context.table
                throw error
            }
        } (&self.table, &self.output[type: Encoder.type])
    }
}
