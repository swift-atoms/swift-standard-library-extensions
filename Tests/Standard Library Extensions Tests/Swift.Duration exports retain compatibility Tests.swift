import Standard_Library_Extensions
import Testing

@Suite struct `Duration exports retain compatibility` {
    private func throughProtocol<D: Standard_Library_Extensions.Duration.`Protocol`>(
        _ value: D
    ) -> D { value }

    @Test func `the qualified duration alias retains native identity through the aggregate`() {
        let qualified: Standard_Library_Extensions.Duration = .milliseconds(-1250)
        let native: Swift.Duration = throughProtocol(qualified)
        let unqualified: Duration = native
        #expect(
            ObjectIdentifier(Standard_Library_Extensions.Duration.self)
                == ObjectIdentifier(Swift.Duration.self)
        )
        #expect(unqualified == .milliseconds(-1250))
        #expect(unqualified.inSeconds == -1.25)
        #expect(unqualified.inMilliseconds == -1250)
        #expect(unqualified.inMicroseconds == -1_250_000)
        #expect(unqualified.inNanoseconds == -1_250_000_000)
    }

    @Test func `reexported duration conversions include the native storage boundary`() {
        let duration = Standard_Library_Extensions.Duration(attoseconds: .max)
        #expect(duration.inSeconds.bitPattern == 0x4422725dd1d243ac)
        #expect(duration.inMilliseconds.bitPattern == 0x44c203af9ee75616)
        #expect(duration.inMicroseconds.bitPattern == 0x45619799812dea11)
        #expect(duration.inNanoseconds.bitPattern == 0x46012e0be826d695)
    }
}
