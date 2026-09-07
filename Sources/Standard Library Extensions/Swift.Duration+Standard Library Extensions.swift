extension Swift.Duration {

    public var inSeconds: Double {
        Double(attoseconds) / 1_000_000_000_000_000_000
    }

    public var inMilliseconds: Double {
        inSeconds * 1_000
    }

    public var inMicroseconds: Double {
        inSeconds * 1_000_000
    }

    public var inNanoseconds: Double {
        inSeconds * 1_000_000_000
    }
}
