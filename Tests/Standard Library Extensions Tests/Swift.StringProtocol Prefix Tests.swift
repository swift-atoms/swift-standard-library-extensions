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

    @Test
    func `lowercasingFirst lowers only the first character`() {
        #expect("Reminder".lowercasingFirst == "reminder")
        #expect("URLRequest".lowercasingFirst == "uRLRequest")
        #expect("".lowercasingFirst == "")
    }

    @Test
    func `lowercasingLeadingUppercase lowers a leading acronym but keeps the next word's capital`() {
        #expect("Reminder".lowercasingLeadingUppercase == "reminder")
        #expect("URLRequest".lowercasingLeadingUppercase == "urlRequest")
        #expect("URL".lowercasingLeadingUppercase == "url")
        #expect("iPhone".lowercasingLeadingUppercase == "iPhone")
        #expect(String.lowercasingLeadingUppercase("RemindersList") == "remindersList")
        #expect("".lowercasingLeadingUppercase == "")
    }
}
