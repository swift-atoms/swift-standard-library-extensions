extension Swift.MutableCollection where Index == Int {

    @inlinable
    public mutating func move(offsets: some Sequence<Int>, to destination: Int) {
        moveSubranges(RangeSet(offsets, within: self), to: destination)
    }
}

extension Swift.MutableCollection where Self: RangeReplaceableCollection, Index == Int {

    @inlinable
    public func moving(offsets: some Sequence<Int>, to destination: Int) -> Self {
        var copy = self
        copy.move(offsets: offsets, to: destination)
        return copy
    }
}

extension Swift.Sequence {

    @inlinable
    public func moving<Result: RangeReplaceableCollection & MutableCollection>(
        offsets: some Sequence<Int>,
        to destination: Int
    ) -> Result where Result.Element == Element, Result.Index == Int {
        var result = Result(self)
        result.move(offsets: offsets, to: destination)
        return result
    }
}
