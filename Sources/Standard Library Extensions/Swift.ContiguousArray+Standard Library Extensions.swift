extension Swift.ContiguousArray {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: ContiguousArray<Element>) -> [Element] {
            Array(expression)
        }

        @inlinable
        public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> [Element]
        where S.Element == Element {
            Array(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> [Element] {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildPartialBlock(first: [Element]) -> [Element] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Element] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Element] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming [Element],
            next: [Element]
        ) -> [Element] {
            accumulated.append(contentsOf: next)
            return accumulated
        }

        @inlinable
        public static func buildBlock() -> [Element] {
            []
        }

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Element]) -> [Element] {
            first
        }

        @inlinable
        public static func buildEither(second: [Element]) -> [Element] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
            component
        }

        @inlinable
        public static func buildFinalResult(_ component: [Element]) -> ContiguousArray<Element> {
            ContiguousArray(component)
        }
    }
}

extension Swift.ContiguousArray {

    @inlinable
    public init(@ContiguousArray.Builder _ builder: () -> ContiguousArray<Element>) {
        self = builder()
    }
}

extension Swift.ContiguousArray {

}
