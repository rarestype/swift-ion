extension Ion {
    @usableFromInline protocol Encoder: ~Copyable {
        static var type: Ion.AnyType { get }
        /// Acquire a semantically-borrowed instance of ``NodeEncoder``, returning a value that
        /// should not outlive the original instance.
        ///
        /// As long as the compiler can prove this, the `consuming` refcount increment should be
        /// optimized away.
        static func acquire(context: consuming NodeEncoder) -> Self
        consuming func release() -> NodeEncoder
    }
}
