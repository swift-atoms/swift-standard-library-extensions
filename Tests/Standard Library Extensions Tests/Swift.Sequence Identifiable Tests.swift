import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Sequence First by Identifier` {

    struct Item: Identifiable, Equatable {
        var id: Int
        var name: String
    }

    @Test
    func `first(id:) finds the element with the identifier or nothing`() {
        let items = [Item(id: 1, name: "one"), Item(id: 2, name: "two"), Item(id: 2, name: "second two")]
        #expect(items.first(id: 2) == Item(id: 2, name: "two"))
        #expect(items.first(id: 3) == nil)
        #expect(Array.first(items, id: 1) == items[0])
    }
}
