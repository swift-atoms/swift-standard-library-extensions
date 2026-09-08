@inlinable
@_disfavoredOverload
public func withUnsafeTemporaryAllocation<T, E: Swift.Error>(
    of type: T.Type,
    capacity: Int,
    _ body: (UnsafeMutableBufferPointer<T>) throws(E) -> Void
) throws(E) {
    var thrown: E? = nil
    Swift.withUnsafeTemporaryAllocation(of: type, capacity: capacity) { buffer in
        do throws(E) {
            unsafe try body(buffer)
        } catch {
            thrown = error
        }
    }
    if let thrown { throw thrown }
}

@inlinable
@_disfavoredOverload
public func withUnsafeTemporaryAllocation<E: Swift.Error>(
    byteCount: Int,
    alignment: Int,
    _ body: (UnsafeMutableRawBufferPointer) throws(E) -> Void
) throws(E) {
    var thrown: E? = nil
    Swift.withUnsafeTemporaryAllocation(byteCount: byteCount, alignment: alignment) {
        buffer in
        do throws(E) {
            unsafe try body(buffer)
        } catch {
            thrown = error
        }
    }
    if let thrown { throw thrown }
}

@inlinable
public func withUnsafeTemporaryAllocation<R, E: Swift.Error>(
    byteCount: Int,
    alignment: Int,
    _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
) throws(E) -> R {
    let result: Swift.Result<R, E> = Swift.withUnsafeTemporaryAllocation(
        byteCount: byteCount,
        alignment: alignment
    ) { buffer in
        do throws(E) {
            return .success(try unsafe body(buffer))
        } catch {
            return .failure(error)
        }
    }
    return try result.get()
}

@inlinable
public func withUnsafeTemporaryAllocation<T, R, E: Swift.Error>(
    of type: T.Type,
    capacity: Int,
    _ body: (UnsafeMutableBufferPointer<T>) throws(E) -> R
) throws(E) -> R {
    let result: Swift.Result<R, E> = Swift.withUnsafeTemporaryAllocation(
        of: type,
        capacity: capacity
    ) { buffer in
        do throws(E) {
            return .success(try unsafe body(buffer))
        } catch {
            return .failure(error)
        }
    }
    return try result.get()
}
