extension Ion.Struct {
    @frozen @usableFromInline struct Iterator {
        @usableFromInline var input: Ion.Input
        @inlinable init(input: Ion.Input) {
            self.input = input
        }
    }
}
extension Ion.Struct.Iterator {
    @usableFromInline mutating func next(
    ) throws(Ion.InputError) -> (id: Ion.Symbol.ID, node: Ion.Node)? {
        if  self.input.exhausted {
            return nil
        }
        /// unlike symbol values, symbols in field names are encoded as VarUInts
        let id: Ion.Symbol.ID = .init(rawValue: try self.input.parse())
        if  let node: Ion.Node = try self.input.parseInner() {
            return (id, node)
        } else {
            // last value is no-op padding, which is legal and means the key should be ignored
            return nil
        }
    }
}

extension Ion.Struct.Iterator: IteratorProtocol {
    @usableFromInline mutating func next(
    ) -> Result<(id: Ion.Symbol.ID, node: Ion.Node?), Ion.InputError>? {
        do {
            guard let field: (id: Ion.Symbol.ID, node: Ion.Node?) = try self.next() else {
                return nil
            }
            return .success(field)
        } catch let error {
            return .failure(error)
        }
    }
}
