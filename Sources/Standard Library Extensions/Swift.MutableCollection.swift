extension Swift.MutableCollection where Index == Int {

    /// SwiftUI's `move(fromOffsets:toOffset:)` for a platform-free domain: the
    /// elements at `offsets` land, in order, before the element at `destination`.
    /// Both are measured in the original coordinates.
    @inlinable
    public mutating func move(offsets: some Sequence<Int>, to destination: Int) {
        moveSubranges(RangeSet(offsets, within: self), to: destination)
    }
}

extension Swift.MutableCollection where Self: RangeReplaceableCollection, Index == Int {

    /// Non-mutating `move(offsets:to:)`; returns the receiver's own type.
    @inlinable
    public func moving(offsets: some Sequence<Int>, to destination: Int) -> Self {
        var copy = self
        copy.move(offsets: offsets, to: destination)
        return copy
    }
}

extension Swift.Sequence {

    /// Any sequence into the range-replaceable container the caller names.
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
