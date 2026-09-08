extension Swift.Collection {

    @inlinable
    public subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    @inlinable
    public subscript(safe range: Range<Index>) -> SubSequence? {
        guard range.lowerBound >= startIndex,
            range.upperBound <= endIndex,
            range.lowerBound <= range.upperBound
        else { return nil }
        return self[range]
    }

    @inlinable
    public func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var chunks: [[Element]] = []
        var currentChunk: [Element] = []
        currentChunk.reserveCapacity(size)

        for element in self {
            currentChunk.append(element)
            if currentChunk.count == size {
                chunks.append(currentChunk)
                currentChunk = []
                currentChunk.reserveCapacity(size)
            }
        }

        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }

        return chunks
    }

    @inlinable
    public func split(at index: Index) -> (SubSequence, SubSequence) {
        (self[startIndex..<index], self[index..<endIndex])
    }

    @inlinable
    public func withContiguousStorageIfAvailable<T, E: Swift.Error>(
        body: (UnsafeBufferPointer<Element>) throws(E) -> T
    ) throws(E) -> T? {
        var result: Swift.Result<T, E>?
        _ = self.withContiguousStorageIfAvailable { buffer in
            do throws(E) {
                result = .success(try unsafe body(buffer))
            } catch {
                result = .failure(error)
            }
        }
        guard let result else { return nil }
        return try result.get()
    }
}

extension Swift.Collection where Element: Hashable {

    @inlinable
    public func trimming(_ elementsToTrim: Set<Element>) -> SubSequence {
        trimming { elementsToTrim.contains($0) }
    }
}

extension Swift.Collection {

    @inlinable
    public func trimming(where predicate: (Element) -> Bool) -> SubSequence {
        var start = startIndex
        var end = startIndex
        var foundStart = false
        var current = startIndex

        while current < endIndex {
            if !predicate(self[current]) {
                if !foundStart {
                    start = current
                    foundStart = true
                }
                end = index(after: current)
            }
            current = index(after: current)
        }

        guard foundStart else {
            return self[startIndex..<startIndex]
        }
        return self[start..<end]
    }
}
