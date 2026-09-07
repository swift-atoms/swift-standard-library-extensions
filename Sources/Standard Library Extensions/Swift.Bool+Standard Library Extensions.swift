extension Swift.Bool {

    public enum Builder {

        @resultBuilder
        public enum All {

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                expression
            }

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                true
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated && next
            }

            @inlinable
            public static func buildBlock() -> Bool {
                true
            }

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? true
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.allSatisfy { $0 }
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }

        @resultBuilder
        public enum `Any` {

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                expression
            }

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                false
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated || next
            }

            @inlinable
            public static func buildBlock() -> Bool {
                false
            }

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? false
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.contains(true)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }

        @resultBuilder
        public enum Count {

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Int {
                expression ? 1 : 0
            }

            @inlinable
            public static func buildPartialBlock(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Int {
                0
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Int {}

            @inlinable
            public static func buildPartialBlock(accumulated: Int, next: Int) -> Int {
                accumulated + next
            }

            @inlinable
            public static func buildBlock() -> Int {
                0
            }

            @inlinable
            public static func buildOptional(_ component: Int?) -> Int {
                component ?? 0
            }

            @inlinable
            public static func buildEither(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildEither(second: Int) -> Int {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Int]) -> Int {
                components.reduce(0, +)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Int) -> Int {
                component
            }
        }

        @resultBuilder
        public enum One {

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Int {
                expression ? 1 : 0
            }

            @inlinable
            public static func buildPartialBlock(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Int {
                0
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Int {}

            @inlinable
            public static func buildPartialBlock(accumulated: Int, next: Int) -> Int {
                accumulated + next
            }

            @inlinable
            public static func buildBlock() -> Int {
                0
            }

            @inlinable
            public static func buildOptional(_ component: Int?) -> Int {
                component ?? 0
            }

            @inlinable
            public static func buildEither(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildEither(second: Int) -> Int {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Int]) -> Int {
                components.reduce(0, +)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Int) -> Int {
                component
            }

            @inlinable
            public static func buildFinalResult(_ component: Int) -> Bool {
                component == 1
            }
        }

        @resultBuilder
        public enum None {

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                !expression
            }

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                true
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated && next
            }

            @inlinable
            public static func buildBlock() -> Bool {
                true
            }

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? true
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.allSatisfy { $0 }
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }
    }
}

extension Swift.Bool {

    @inlinable
    public static func all(@Builder.All _ builder: () -> Bool) -> Bool {
        builder()
    }

    @inlinable
    public static func any(@Builder.`Any` _ builder: () -> Bool) -> Bool {
        builder()
    }

    @inlinable
    public static func count(@Builder.Count _ builder: () -> Int) -> Int {
        builder()
    }

    @inlinable
    public static func one(@Builder.One _ builder: () -> Bool) -> Bool {
        builder()
    }

    @inlinable
    public static func none(@Builder.None _ builder: () -> Bool) -> Bool {
        builder()
    }
}

extension Swift.Bool {

    @inlinable
    public var int: Int { self ? 1 : 0 }
}
