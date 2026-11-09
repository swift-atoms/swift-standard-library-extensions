extension Swift.FloatingPoint {

    @inlinable
    public func isApproximatelyEqual(to other: Self, tolerance: Self) -> Bool {
        abs(self - other) <= tolerance
    }

    @inlinable
    public func lerp(to other: Self, t: Self) -> Self {
        self + t * (other - self)
    }

    @inlinable
    public func power(_ exponent: Int) -> Self {
        var result: Self = 1
        var base = self
        var n = exponent.magnitude

        while n > 0 {
            if n & 1 == 1 {
                result *= base
            }
            base *= base
            n >>= 1
        }
        return exponent < 0 ? 1 / result : result
    }

    @inlinable
    public func rounded(to places: Int) -> Self {
        guard places >= 0 else { return self }
        let divisor = Self(10).power(places)
        return (self * divisor).rounded() / divisor
    }
}
