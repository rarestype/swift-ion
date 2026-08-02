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
    @inline(always) @inlinable mutating func bind<Encoder, T, E>(
        to _: Encoder.Type = Encoder.self,
        with yield: (inout Encoder) throws(E) -> T
    ) throws(E) -> T where Encoder: ~Copyable & Ion.Encoder, T: ~Copyable {
        try { (table: inout Ion.SymbolEncoder, output: inout Ion.Output) throws(E) in
            let context: Ion.NodeEncoder
            var encoder: Encoder = .acquire(
                context: .init(table: consume table, output: consume output)
            )
            do throws(E) {
                let value: T = try yield(&encoder)
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
