import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Keywords Tests` {
    @Test(arguments: [
        "associatedtype", "deinit", "rethrows", "precedencegroup", "Any",
        "await", "class", "func", "self", "Self", "throws", "while",
    ])
    func `escape wraps a reserved word in backticks`(keyword: String) {
        #expect(Set<String>.swift.escape(keyword) == "`\(keyword)`")
    }

    @Test(arguments: ["name", "value", "keywords", "Int", "_value"])
    func `escape leaves an ordinary identifier unchanged`(identifier: String) {
        #expect(Set<String>.swift.escape(identifier) == identifier)
    }
}
