extension Ion.Node {
    @frozen public struct Types {
        /// The first type in the list is special — for example, `$ion_symbol_table` is only
        /// meaningful in this position when applied to a struct.
        @usableFromInline var first: Ion.Symbol.ID
        @usableFromInline var extra: [Ion.Symbol.ID]

        @inlinable init(first: Ion.Symbol.ID, extra: [Ion.Symbol.ID] = []) {
            self.first = first
            self.extra = extra
        }
    }
}
extension Ion.Node.Types {
    @inline(always) @inlinable static var mask: UInt8 { 0xe0 }
}
