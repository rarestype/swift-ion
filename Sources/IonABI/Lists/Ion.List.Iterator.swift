extension Ion.List {
    @frozen @usableFromInline struct Iterator {
        @usableFromInline var input: Ion.Input
        @inlinable init(input: Ion.Input) {
            self.input = input
        }
    }
}
extension Ion.List.Iterator {
    @usableFromInline mutating func next() throws(Ion.InputError) -> Ion.Node? {
        if  self.input.exhausted {
            return nil
        } else {
            return try self.input.parseInner()
        }
    }
}
extension Ion.List.Iterator: IteratorProtocol {
    @usableFromInline mutating func next() -> Result<Ion.Node, Ion.InputError>? {
        do {
            guard let value: Ion.Node = try self.next() else {
                return nil
            }
            return .success(value)
        } catch let error {
            return .failure(error)
        }
    }
}
