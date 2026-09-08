extension Swift.Array {

    @inlinable
    public func removing(at index: Int) -> [Element] {
        var result = self
        result.remove(at: index)
        return result
    }

    @inlinable
    public func inserting(_ element: Element, at index: Int) -> [Element] {
        var result = self
        result.insert(element, at: index)
        return result
    }

    @inlinable
    public subscript(safe range: Range<Int>) -> ArraySlice<Element>? {
        guard range.lowerBound >= 0,
            range.upperBound <= count,
            range.lowerBound <= range.upperBound
        else { return nil }
        return self[range]
    }

    @inlinable
    public subscript(safe range: ClosedRange<Int>) -> ArraySlice<Element>? {
        guard range.lowerBound >= 0,
            range.upperBound < count,
            range.lowerBound <= range.upperBound
        else { return nil }
        return self[range]
    }

    @inlinable
    @_disfavoredOverload
    public func withUnsafeBufferPointer<T, E: Swift.Error>(
        body: (UnsafeBufferPointer<Element>) throws(E) -> T
    ) throws(E) -> T {
        let result: Swift.Result<T, E> = self.withUnsafeBufferPointer { buffer in
            do throws(E) {
                return .success(try unsafe body(buffer))
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }

    @inlinable
    @_disfavoredOverload
    public mutating func withUnsafeMutableBufferPointer<T, E: Swift.Error>(
        body: (inout UnsafeMutableBufferPointer<Element>) throws(E) -> T
    ) throws(E) -> T {
        var result: Swift.Result<T, E>?
        self.withUnsafeMutableBufferPointer { buffer in
            do throws(E) {
                result = .success(try unsafe body(&buffer))
            } catch {
                result = .failure(error)
            }
        }
        return try unsafe result.unsafelyUnwrapped.get()
    }
}

extension Swift.Array {

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
    }
}

extension Swift.Array {

    @inlinable
    public init(@Array.Builder _ builder: () -> [Element]) {
        self = builder()
    }
}
