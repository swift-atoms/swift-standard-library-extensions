extension Swift.CollectionOfOne {

}

extension Swift.CollectionOfOne {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Element) -> Element {
            expression
        }

        @inlinable
        public static func buildBlock(_ component: Element) -> Element {
            component
        }

        @inlinable
        public static func buildEither(first: Element) -> Element {
            first
        }

        @inlinable
        public static func buildEither(second: Element) -> Element {
            second
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Element) -> Element {
            component
        }

        @inlinable
        public static func buildFinalResult(_ component: Element) -> CollectionOfOne<Element> {
            CollectionOfOne(component)
        }
    }
}

extension Swift.CollectionOfOne {

    @inlinable
    public init(@CollectionOfOne.Builder _ builder: () -> CollectionOfOne<Element>) {
        self = builder()
    }
}
