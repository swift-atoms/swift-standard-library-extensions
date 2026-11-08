import Testing

@testable import Standard_Library_Extensions

@Suite
struct `SetAlgebra Toggle and Replace` {

    @Test
    func `Toggling inserts an absent member and removes a present one`() {
        var set: Set = [1, 2]
        set.toggle(3)
        #expect(set == [1, 2, 3])
        set.toggle(1)
        #expect(set == [2, 3])
        #expect(Set.toggling([1], 1) == [])
    }

    @Test
    func `Replacing swaps a present member and leaves an absent one alone`() {
        var set: Set = ["a", "b"]
        set.replace("a", with: "c")
        #expect(set == ["b", "c"])
        set.replace("z", with: "y")
        #expect(set == ["b", "c"])
        #expect(Set.replacing(["a"], "a", with: "b") == ["b"])
    }
}
