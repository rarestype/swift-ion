extension Ion.Struct {
    struct Index {
        let id: Ion.Symbol.ID
        let offset: Int
        let header: Ion.Header
    }
}
extension Ion.Struct.Index {
    var range: Range<Int> {
        self.offset ..< self.offset + self.header.size
    }
}
