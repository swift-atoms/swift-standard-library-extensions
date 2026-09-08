extension Swift.Range {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Range<Bound>) -> [Range<Bound>] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Range<Bound>]) -> [Range<Bound>] {
            expression
        }

        @inlinable
        public static func buildPartialBlock(first: [Range<Bound>]) -> [Range<Bound>] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Range<Bound>] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Range<Bound>] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: [Range<Bound>],
            next: [Range<Bound>]
        ) -> [Range<Bound>] {
            accumulated + next
        }

        @inlinable
        public static func buildBlock() -> [Range<Bound>] {
            []
        }

        @inlinable
        public static func buildOptional(_ component: [Range<Bound>]?) -> [Range<Bound>] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Range<Bound>]) -> [Range<Bound>] {
            first
        }

        @inlinable
        public static func buildEither(second: [Range<Bound>]) -> [Range<Bound>] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Range<Bound>]]) -> [Range<Bound>] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Range<Bound>]) -> [Range<Bound>] {
            component
        }
    }
}

extension Swift.Range {

    @inlinable
    public static func build(
        @Range<Bound>.Builder _ builder: () -> [Range<Bound>]
    ) -> [Range<Bound>] {
        builder()
    }
}

extension Swift.Range where Bound: Strideable {

    @inlinable
    public func overlap(_ other: Range<Bound>) -> Range<Bound>? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)

        guard lower < upper else { return nil }
        return lower..<upper
    }

    @inlinable
    public func clamped(to bounds: Range<Bound>) -> Range<Bound>? {
        overlap(bounds)
    }

    @inlinable
    public func split(at point: Bound) -> (lower: Range<Bound>, upper: Range<Bound>)? {
        guard contains(point), point != lowerBound else { return nil }
        return (lowerBound..<point, point..<upperBound)
    }
}
