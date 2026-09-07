#if !hasFeature(Embedded)
@inlinable
    public func withUnsafeContinuation<T>(
        _ fn: (UnsafeContinuation<T, Never>) -> Void
    ) async -> T {
        await unsafe _Concurrency.withUnsafeContinuation(fn)
    }
#endif
