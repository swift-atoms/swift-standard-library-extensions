extension Swift.StringProtocol where UTF8View.Index == Index {

    @inlinable
    public func range(of string: some StringProtocol) -> Range<Index>? {
        guard !string.isEmpty else { return startIndex..<startIndex }

        let needle = string.utf8
        let needleCount = needle.count
        let haystackCount = utf8.count
        guard needleCount <= haystackCount else { return nil }

        let lastStart = utf8.index(utf8.startIndex, offsetBy: haystackCount - needleCount)
        var start = utf8.startIndex

        while start <= lastStart {
            var h = start
            var n = needle.startIndex
            while n < needle.endIndex, utf8[h] == needle[n] {
                h = utf8.index(after: h)
                n = needle.index(after: n)
            }
            if n == needle.endIndex {
                return start..<h
            }
            start = utf8.index(after: start)
        }

        return nil
    }
}

extension Swift.StringProtocol {

    @inlinable
    public static func trimming(
        _ string: Self,
        where predicate: (Character) -> Bool
    ) -> SubSequence {
        var start = string.startIndex
        var end = string.endIndex

        while start < end, predicate(string[start]) {
            start = string.index(after: start)
        }

        while end > start, predicate(string[string.index(before: end)]) {
            end = string.index(before: end)
        }

        return string[start..<end]
    }

    @inlinable
    public static func trimming(
        _ string: Self,
        of characterSet: Set<Character>
    ) -> SubSequence {
        trimming(string, where: characterSet.contains)
    }

    @inlinable
    public func trimming(where predicate: (Character) -> Bool) -> SubSequence {
        Self.trimming(self, where: predicate)
    }

    @inlinable
    @_disfavoredOverload
    public func trimming(_ characterSet: Set<Character>) -> SubSequence {
        Self.trimming(self, of: characterSet)
    }

    @inlinable
    public func trimming(_ characterSet: Set<Character>) -> String {
        String(Self.trimming(self, of: characterSet))
    }
}
