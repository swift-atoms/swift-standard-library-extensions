extension Swift.String {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S) -> String {
            String(expression)
        }

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S?) -> String {
            expression.map { String($0) } ?? ""
        }

        @inlinable
        public static func buildPartialBlock(first: String) -> String {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> String {
            ""
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> String {}

        @inlinable
        public static func buildPartialBlock(accumulated: String, next: String) -> String {
            if accumulated.isEmpty {
                next
            } else {
                accumulated + "\n" + next
            }
        }

        @inlinable
        public static func buildBlock() -> String {
            ""
        }

        @inlinable
        public static func buildOptional(_ component: String?) -> String {
            component ?? ""
        }

        @inlinable
        public static func buildEither(first: String) -> String {
            first
        }

        @inlinable
        public static func buildEither(second: String) -> String {
            second
        }

        @inlinable
        public static func buildArray(_ components: [String]) -> String {
            components.joined(separator: "\n")
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: String) -> String {
            component
        }
    }
}

extension Swift.String {

    @inlinable
    public init(@Builder _ builder: () -> String) {
        self = builder()
    }
}

extension Swift.String {

    @inlinable
    public var lines: [String] {
        split(whereSeparator: { $0.isNewline }).map(Self.init)
    }

    @inlinable
    public var words: [String] {
        split(whereSeparator: { $0.isWhitespace }).map(Self.init)
    }
}
