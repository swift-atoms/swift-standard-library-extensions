#if !hasFeature(Embedded)
extension Swift.Actor {

        @inlinable
        public func run<R, Failure: Swift.Error>(
            _ body: @Sendable (isolated Self) throws(Failure) -> sending R
        ) throws(Failure) -> sending R {
            try body(self)
        }

        @inlinable
        public func run<R, Failure: Swift.Error>(
            _ body: @Sendable (isolated Self) async throws(Failure) -> sending R
        ) async throws(Failure) -> sending R {
            try await body(self)
        }
    }
#endif


#if !hasFeature(Embedded)
extension Swift.Actor {

        @inlinable
        public func run<R: ~Copyable, Failure: Swift.Error>(
            _ body: @Sendable (isolated Self) throws(Failure) -> sending R
        ) throws(Failure) -> sending R {
            try body(self)
        }

        @inlinable
        public func run<R: ~Copyable, Failure: Swift.Error>(
            _ body: @Sendable (isolated Self) async throws(Failure) -> sending R
        ) async throws(Failure) -> sending R {
            try await body(self)
        }
    }
#endif
