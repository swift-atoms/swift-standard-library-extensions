extension AsyncSequence where Self: Sendable, Element: Sendable {
    /// Preserve values, errors and producer cancellation while erasing the sequence type.
    public func eraseToThrowingStream() -> AsyncThrowingStream<Element, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await value in self {
                        if Task.isCancelled { break }
                        continuation.yield(value)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
