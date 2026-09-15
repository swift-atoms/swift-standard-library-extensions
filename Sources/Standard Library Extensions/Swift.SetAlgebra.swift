extension Swift.SetAlgebra {

    /// The set without the member if it was present, with it if it was absent.
    @inlinable
    public static func toggling(_ set: Self, _ member: Element) -> Self {
        var result = set
        if result.remove(member) == nil { result.insert(member) }
        return result
    }

    @inlinable
    public mutating func toggle(_ member: Element) {
        self = Self.toggling(self, member)
    }

    /// The set with `member` swapped for `replacement` when it is present; unchanged otherwise.
    @inlinable
    public static func replacing(_ set: Self, _ member: Element, with replacement: Element) -> Self {
        var result = set
        if result.remove(member) != nil { result.insert(replacement) }
        return result
    }

    @inlinable
    public mutating func replace(_ member: Element, with replacement: Element) {
        self = Self.replacing(self, member, with: replacement)
    }
}
