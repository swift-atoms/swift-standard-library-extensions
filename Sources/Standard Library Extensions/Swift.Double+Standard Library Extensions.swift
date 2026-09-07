extension Swift.Double {

    @inlinable
    public func rounded(to places: Int) -> Double {
        guard places >= 0 else { return self }
        var divisor: Double = 1.0
        for _ in 0..<places {
            divisor *= 10.0
        }
        return (self * divisor).rounded() / divisor
    }
}
