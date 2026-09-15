import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Optional - Extensions` {

    @Test
    func `isPresent reads whether a value is present`() {
        let present: Int? = 1
        let absent: Int? = nil
        #expect(present.isPresent)
        #expect(!absent.isPresent)
    }

    @Test
    func `Setting isPresent false clears the value`() {
        var value: Int? = 1
        value.isPresent = false
        #expect(value == nil)
    }

    @Test
    func `Setting isPresent true leaves the value alone`() {
        var present: Int? = 1
        present.isPresent = true
        #expect(present == 1)
        var absent: Int? = nil
        absent.isPresent = true
        #expect(absent == nil)
    }
}
