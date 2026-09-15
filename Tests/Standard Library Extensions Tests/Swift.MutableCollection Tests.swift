import Testing

@testable import Standard_Library_Extensions

@Suite
struct `MutableCollection move` {

    @Test
    func `Moving one element forward lands it before the destination`() {
        #expect(["a", "b", "c", "d"].moving(offsets: [0], to: 3) == ["b", "c", "a", "d"])
    }

    @Test
    func `Moving several elements keeps their order`() {
        #expect([1, 2, 3, 4, 5].moving(offsets: [1, 3], to: 0) == [2, 4, 1, 3, 5])
    }

    @Test
    func `Unsorted and repeated offsets are normalised`() {
        #expect([1, 2, 3, 4, 5].moving(offsets: [3, 1, 3], to: 0) == [2, 4, 1, 3, 5])
    }

    @Test
    func `Moving to the end appends`() {
        #expect([1, 2, 3].moving(offsets: [0], to: 3) == [2, 3, 1])
    }

    @Test
    func `A destination inside the moved block is an identity`() {
        #expect([1, 2, 3].moving(offsets: [1], to: 2) == [1, 2, 3])
    }

    @Test
    func `The mutating form works in place`() {
        var array = [1, 2, 3]
        array.move(offsets: [2], to: 0)
        #expect(array == [3, 1, 2])
    }

    @Test
    func `The non-mutating form keeps the receiver's type`() {
        let moved = ContiguousArray([1, 2, 3]).moving(offsets: [2], to: 0)
        #expect(moved == ContiguousArray([3, 1, 2]))
    }

    @Test
    func `Any sequence lifts into the container the caller names`() {
        let moved: ContiguousArray<Int> = (1...3).moving(offsets: [2], to: 0)
        #expect(moved == ContiguousArray([3, 1, 2]))
    }
}
