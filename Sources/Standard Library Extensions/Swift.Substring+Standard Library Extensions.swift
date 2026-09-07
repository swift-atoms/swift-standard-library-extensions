extension Swift.Substring {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S) -> String {
            String.Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S?) -> String {
            String.Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildPartialBlock(first: String) -> String {
            String.Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> String {
            String.Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> String {}

        @inlinable
        public static func buildPartialBlock(accumulated: String, next: String) -> String {
            String.Builder.buildPartialBlock(accumulated: accumulated, next: next)
        }

        @inlinable
        public static func buildBlock() -> String {
            String.Builder.buildBlock()
        }

        @inlinable
        public static func buildOptional(_ component: String?) -> String {
            String.Builder.buildOptional(component)
        }

        @inlinable
        public static func buildEither(first: String) -> String {
            String.Builder.buildEither(first: first)
        }

        @inlinable
        public static func buildEither(second: String) -> String {
            String.Builder.buildEither(second: second)
        }

        @inlinable
        public static func buildArray(_ components: [String]) -> String {
            String.Builder.buildArray(components)
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: String) -> String {
            String.Builder.buildLimitedAvailability(component)
        }

        @inlinable
        public static func buildFinalResult(_ component: String) -> Substring {
            Substring(component)
        }
    }
}

extension Swift.Substring {

    @inlinable
    public init(@Builder _ builder: () -> Substring) {
        self = builder()
    }
}
