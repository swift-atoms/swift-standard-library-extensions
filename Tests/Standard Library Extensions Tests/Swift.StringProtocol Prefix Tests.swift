import Testing

@testable import Standard_Library_Extensions

@Suite
struct `StringProtocol Prefix and First Letter` {

    @Test
    func `removing(prefix:) gives the rest or nothing`() {
        #expect("list_abc".removing(prefix: "list_") == "abc")
        #expect("#tag".removing(prefix: "#") == "tag")
        #expect("#".removing(prefix: "#") == "")
        #expect("abc".removing(prefix: "list_") == nil)
        #expect(String.removing("xy", prefix: "") == "xy")
    }

    @Test
    func `uppercasingFirst touches only the first character`() {
        #expect("weekly".uppercasingFirst == "Weekly")
        #expect("Weekly".uppercasingFirst == "Weekly")
        #expect("".uppercasingFirst == "")
        #expect("éa".uppercasingFirst == "Éa")
        #expect(Substring("ab cD").uppercasingFirst == "Ab cD")
    }
}
