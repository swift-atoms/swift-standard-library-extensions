extension Swift.Set.Cartesian {

    @inlinable
    public func product<Other>(_ other: Set<Other>) -> [(Element, Other)] {
        var result: [(Element, Other)] = []
        result.reserveCapacity(base.count * other.count)

        for element in base {
            for otherElement in other {
                result.append((element, otherElement))
            }
        }

        return result
    }

    @inlinable
    public func square() -> [(Element, Element)] {
        product(base)
    }
}
