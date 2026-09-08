extension Swift.Optional {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Wrapped) -> Wrapped? {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: Wrapped?) -> Wrapped? {
            expression
        }

        @inlinable
        public static func buildPartialBlock(first: Wrapped?) -> Wrapped? {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> Wrapped? {
            nil
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> Wrapped? {}

        @inlinable
        public static func buildPartialBlock(accumulated: Wrapped?, next: Wrapped?) -> Wrapped? {
            accumulated ?? next
        }

        @inlinable
        public static func buildBlock() -> Wrapped? {
            nil
        }

        @inlinable
        public static func buildOptional(_ component: Wrapped??) -> Wrapped? {
            component.flatMap { $0 }
        }

        @inlinable
        public static func buildEither(first: Wrapped?) -> Wrapped? {
            first
        }

        @inlinable
        public static func buildEither(second: Wrapped?) -> Wrapped? {
            second
        }

        @inlinable
        public static func buildArray(_ components: [Wrapped?]) -> Wrapped? {
            for component in components {
                if let value = component {
                    return value
                }
            }
            return nil
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Wrapped?) -> Wrapped? {
            component
        }
    }
}

extension Swift.Optional {

    @inlinable
    public static func first(@Optional<Wrapped>.Builder _ builder: () -> Wrapped?) -> Wrapped? {
        builder()
    }
}

extension Swift.Optional {

    @inlinable
    public func unwrap<E: Swift.Error>(or error: E) throws(E) -> Wrapped {
        guard let value = self else { throw error }
        return value
    }

    @inlinable
    public func apply<Result>(_ transform: ((Wrapped) -> Result)?) -> Result? {
        guard let transform, let value = self else { return nil }
        return transform(value)
    }

    @inlinable
    public func zip<Other>(_ other: Other?) -> (Wrapped, Other)? {
        guard let value = self, let otherValue = other else { return nil }
        return (value, otherValue)
    }

    @inlinable
    public func map<NewWrapped, E: Swift.Error>(
        _ transform: (Wrapped) throws(E) -> NewWrapped
    ) throws(E) -> NewWrapped? {
        guard let value = self else { return nil }
        return try transform(value)
    }
}
