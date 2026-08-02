extension Ion.Struct {
    struct Offsets {
        var input: Ion.Input
        init(input: Ion.Input) {
            self.input = input
        }
    }
}
extension Ion.Struct.Offsets {
    mutating func next() throws(Ion.InputError) -> Ion.Struct.Index? {
        if  self.input.exhausted {
            return nil
        }
        /// unlike symbol values, symbols in field names are encoded as VarUInts
        let id: Ion.Symbol.ID = .init(rawValue: try self.input.parse())
        let header: Ion.Header = try self.input.header()
        return .init(id: id, offset: self.input.index, header: header)
    }
}
extension Ion.Struct.Offsets: IteratorProtocol {
    mutating func next() -> Result<Ion.Struct.Index, Ion.InputError>? {
        do {
            guard let index: Ion.Struct.Index = try self.next() else {
                return nil
            }
            return .success(index)
        } catch let error {
            return .failure(error)
        }
    }
}
