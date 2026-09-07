extension Swift.RangeReplaceableCollection {

    @inlinable
    public func prepending(_ element: Element) -> Self {
        var result = self
        result.insert(element, at: startIndex)
        return result
    }
}

extension Swift.RangeReplaceableCollection where Element: Hashable {

    @inlinable
    public func uniqued() -> Self {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
