extension Swift.Sequence where Element: AdditiveArithmetic {

    @inlinable
    public func sum() -> Element {
        reduce(.zero, +)
    }
}

extension Swift.Sequence {

    @inlinable
    public func count<E: Swift.Error>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int
    {

        var count = 0
        for element in self {
            if try predicate(element) {
                count += 1
            }
        }
        return count
    }

}

extension Swift.Sequence where Element: Hashable {

    @inlinable
    public func frequencies() -> [Element: Int] {
        reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
    }
}

extension Swift.Sequence where Element: Comparable {

    @inlinable
    public func isSorted() -> Bool {
        var previous: Element?

        for element in self {
            if let prev = previous, prev > element {
                return false
            }
            previous = element
        }

        return true
    }

    @inlinable
    public func isSorted<E: Swift.Error>(
        by areInIncreasingOrder: (Element, Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        var previous: Element?

        for element in self {
            if let prev = previous, try !areInIncreasingOrder(prev, element) {
                return false
            }
            previous = element
        }

        return true
    }

    @inlinable
    public func max(count: Int) -> [Element] {
        guard count > 0 else { return [] }
        var result: [Element] = []

        for element in self {
            if result.count < count {
                result.append(element)
                result.sort(by: >)
            } else if let last = result.last, element > last {
                result[result.endIndex - 1] = element
                result.sort(by: >)
            }
        }

        return result
    }

    @inlinable
    public func min(count: Int) -> [Element] {
        guard count > 0 else { return [] }
        var result: [Element] = []

        for element in self {
            if result.count < count {
                result.append(element)
                result.sort()
            } else if let last = result.last, element < last {
                result[result.endIndex - 1] = element
                result.sort()
            }
        }

        return result
    }
}

extension Swift.Sequence where Element: Numeric {

    @inlinable
    public func product() -> Element {
        reduce(1, *)
    }
}

extension Swift.Sequence where Element: BinaryInteger {

    @inlinable
    public func mean() -> Element? {
        let elements = Array(self)
        guard !elements.isEmpty else { return nil }
        return elements.reduce(.zero, +) / Element(elements.count)
    }
}

extension Swift.Sequence where Element: BinaryFloatingPoint {

    @inlinable
    public func mean() -> Element? {
        var sum: Element = 0
        var count: Element = 0

        for element in self {
            sum += element
            count += 1
        }

        guard count > 0 else { return nil }
        return sum / count
    }
}
