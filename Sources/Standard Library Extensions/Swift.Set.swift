extension Swift.Set {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Element) -> Set<Element> {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: Set<Element>) -> Set<Element> {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> Set<Element> {
            Set(expression)
        }

        @inlinable
        public static func buildExpression<S: Sequence>(_ expression: S) -> Set<Element>
        where S.Element == Element {
            Set(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> Set<Element> {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildPartialBlock(first: Set<Element>) -> Set<Element> {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> Set<Element> {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> Set<Element> {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming Set<Element>,
            next: Set<Element>
        ) -> Set<Element> {
            accumulated.formUnion(next)
            return accumulated
        }

        @inlinable
        public static func buildBlock() -> Set<Element> {
            []
        }

        @inlinable
        public static func buildOptional(_ component: Set<Element>?) -> Set<Element> {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: Set<Element>) -> Set<Element> {
            first
        }

        @inlinable
        public static func buildEither(second: Set<Element>) -> Set<Element> {
            second
        }

        @inlinable
        public static func buildArray(_ components: [Set<Element>]) -> Set<Element> {
            components.reduce(into: []) { result, set in
                result.formUnion(set)
            }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Set<Element>) -> Set<Element> {
            component
        }
    }
}

extension Swift.Set {

    @inlinable
    public init(@Set.Builder _ builder: () -> Set<Element>) {
        self = builder()
    }
}

extension Swift.Set {

    @inlinable
    public func partition(
        where predicate: (Element) -> Bool
    ) -> (satisfying: Set<Element>, failing: Set<Element>) {
        var satisfying = Set<Element>()
        var failing = Set<Element>()

        for element in self {
            if predicate(element) {
                satisfying.insert(element)
            } else {
                failing.insert(element)
            }
        }

        return (satisfying, failing)
    }

    @inlinable
    public func subsets(ofSize k: Int) -> Set<Set<Element>> {
        guard k >= 0 else { return [] }
        guard k <= count else { return [] }

        if k == 0 {
            return [[]]
        }

        if k == count {
            return [self]
        }

        var result = Set<Set<Element>>()
        let elements = Array(self)

        func combine(start: Int, current: Set<Element>) {
            if current.count == k {
                result.insert(current)
                return
            }

            for index in elements[start...].indices {
                var next = current
                next.insert(elements[index])
                combine(start: index + 1, current: next)
            }
        }

        combine(start: 0, current: [])
        return result
    }

    @inlinable
    public var cartesian: Cartesian {
        Cartesian(base: self)
    }

    public struct Cartesian {
        @usableFromInline
        internal let base: Set<Element>

        @usableFromInline
        internal init(base: Set<Element>) {
            self.base = base
        }
    }
}
