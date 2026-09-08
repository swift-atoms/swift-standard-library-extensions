extension Swift.Span where Element: Copyable {

    @inlinable
    @_disfavoredOverload
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Element>) throws(E) -> R
    ) throws(E) -> R {
        var thrown: E? = nil
        let result: R? = self.withUnsafeBufferPointer {
            (buffer: UnsafeBufferPointer<Element>) -> R? in
            do throws(E) {
                return try unsafe body(buffer)
            } catch {
                thrown = error
                return nil
            }
        }
        if let thrown { throw thrown }
        return unsafe result.unsafelyUnwrapped
    }
}
