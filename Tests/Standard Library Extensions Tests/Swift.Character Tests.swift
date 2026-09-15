import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Character Separators` {

    @Test
    func `The C0 separators are the ASCII control code points`() {
        #expect(Character.unitSeparator.asciiValue == 0x1F)
        #expect(Character.recordSeparator.asciiValue == 0x1E)
        #expect(Character.groupSeparator.asciiValue == 0x1D)
        #expect(Character.fileSeparator.asciiValue == 0x1C)
    }

    @Test
    func `Joining on the unit separator splits back`() {
        let joined = ["a b", "c"].joined(separator: String(Character.unitSeparator))
        #expect(joined.split(separator: Character.unitSeparator) == ["a b", "c"])
    }
}
