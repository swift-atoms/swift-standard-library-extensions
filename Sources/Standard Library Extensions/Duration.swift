@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias Duration = Swift.Duration

extension Duration {
    public typealias `Protocol` = DurationProtocol
}

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
