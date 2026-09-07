extension Swift.ClosedRange {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: ClosedRange<Bound>) -> [ClosedRange<Bound>]
        {
            [expression]
        }

        @inlinable
        public static func buildExpression(
            _ expression: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: Bound) -> [ClosedRange<Bound>] {
            [expression...expression]
        }

        @inlinable
        public static func buildPartialBlock(first: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [ClosedRange<Bound>] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [ClosedRange<Bound>] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: [ClosedRange<Bound>],
            next: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            accumulated + next
        }

        @inlinable
        public static func buildBlock() -> [ClosedRange<Bound>] {
            []
        }

        @inlinable
        public static func buildOptional(_ component: [ClosedRange<Bound>]?) -> [ClosedRange<Bound>]
        {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            first
        }

        @inlinable
        public static func buildEither(second: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[ClosedRange<Bound>]]) -> [ClosedRange<Bound>]
        {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(
            _ component: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            component
        }
    }
}

extension Swift.ClosedRange {

    @inlinable
    public static func build(
        @ClosedRange<Bound>.Builder _ builder: () -> [ClosedRange<Bound>]
    ) -> [ClosedRange<Bound>] {
        builder()
    }
}

extension Swift.ClosedRange where Bound: Strideable {

    @inlinable
    public func overlap(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)

        guard lower <= upper else { return nil }
        return lower...upper
    }

    @inlinable
    public func clamped(to bounds: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        overlap(bounds)
    }
}
