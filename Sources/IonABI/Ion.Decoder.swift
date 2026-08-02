extension Ion {
    @usableFromInline protocol Decoder: ~Copyable {
        /// Acquire a semantically-borrowed instance of ``NodeDecoder``, returning a value that
        /// should not outlive the original instance.
        ///
        /// As long as the compiler can prove this, the `consuming` refcount increment should be
        /// optimized away.
        static func acquire(context: consuming NodeDecoder) throws -> Self
    }
}
