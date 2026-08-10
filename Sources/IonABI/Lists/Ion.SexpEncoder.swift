extension Ion {
    @frozen @usableFromInline struct SexpEncoder: ~Copyable {
        @usableFromInline var list: ListEncoder
        @inlinable init(list: consuming ListEncoder) {
            self.list = list
        }
    }
}
extension Ion.SexpEncoder: Ion.Encoder {
    @inlinable static var type: Ion.AnyType { .sexp }
    @inlinable static func acquire(context: consuming Ion.NodeEncoder) -> Self {
        .init(list: .acquire(context: context))
    }
    @inlinable consuming func release() -> Ion.NodeEncoder {
        self.list.release()
    }
}
