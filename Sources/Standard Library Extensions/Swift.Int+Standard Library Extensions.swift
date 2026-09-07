extension Swift.Int {

    @inlinable
    public init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}
