extension Swift.BidirectionalCollection where Element: Hashable {

    @inlinable
    public func trimming(_ elementsToTrim: Set<Element>) -> SubSequence {
        trimming { elementsToTrim.contains($0) }
    }
}

extension Swift.BidirectionalCollection {

    @inlinable
    public func trimming(where predicate: (Element) -> Bool) -> SubSequence {
        var start = startIndex
        var end = endIndex

        while start < end && predicate(self[start]) {
            start = index(after: start)
        }

        while start < end {
            let beforeEnd = index(before: end)
            guard predicate(self[beforeEnd]) else { break }
            end = beforeEnd
        }

        return self[start..<end]
    }
}
