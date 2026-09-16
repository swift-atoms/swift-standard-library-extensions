import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Collection Safe Subscript` {

    @Test
    func `Safe subscript returns element for valid index`() {
        let array = [1, 2, 3, 4, 5]
        #expect(array[safe: 0] == 1)
        #expect(array[safe: 2] == 3)
        #expect(array[safe: 4] == 5)
    }

    @Test
    func `Safe subscript with string`() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 1)
        #expect(string[safe: index] == "e")
        #expect(string[safe: string.startIndex] == "H")
    }

    @Test
    func `Safe subscript with dictionary values`() {
        let dict = ["a": 1, "b": 2, "c": 3]
        let values = Array(dict.values.sorted())
        #expect(values[safe: 0] == 1)
        #expect(values[safe: 1] == 2)
        #expect(values[safe: 2] == 3)
    }

    @Test
    func `Safe subscript returns nil for out of bounds positive index`() {
        let array = [1, 2, 3]
        #expect(array[safe: 10] == nil)
        #expect(array[safe: 100] == nil)
    }

    @Test
    func `Safe subscript returns nil for negative index`() {
        let array = [1, 2, 3]
        #expect(array[safe: -1] == nil)
        #expect(array[safe: -10] == nil)
    }

    @Test
    func `Safe subscript on empty collection`() {
        let empty: [Int] = []
        #expect(empty[safe: 0] == nil)
        #expect(empty[safe: 1] == nil)
    }

    @Test
    func `Safe subscript with ArraySlice`() {
        let array = [1, 2, 3, 4, 5]
        let slice = array[1...3]
        #expect(slice[safe: 1] == 2)
        #expect(slice[safe: 2] == 3)
        #expect(slice[safe: 3] == 4)
        #expect(slice[safe: 0] == nil)
        #expect(slice[safe: 4] == nil)
    }

    @Test
    func `Safe subscript with ContiguousArray`() {
        let array: ContiguousArray = [10, 20, 30]
        #expect(array[safe: 0] == 10)
        #expect(array[safe: 2] == 30)
        #expect(array[safe: 3] == nil)
    }

    @Test
    func `Natural transformation preserves structure`() {

        let collection = [1, 2, 3]

        let validResult = collection[safe: 1]
        #expect(validResult != nil)
        #expect(validResult == collection[1])

        let invalidResult = collection[safe: 10]
        #expect(invalidResult == nil)
    }

    @Test
    func `Totality property - never traps`() {
        let array = [1, 2, 3]

        _ = array[safe: -100]
        _ = array[safe: 100]
        _ = array[safe: Int.max]

        #expect(Bool(true))
    }
}

@Suite
struct `Collection Chunks` {

    @Test
    func `Chunks slice the collection without copying elements`() {
        let array = [1, 2, 3, 4, 5]
        let chunks: [ArraySlice<Int>] = array.chunks(of: 2)
        #expect(chunks.map(Array.init) == [[1, 2], [3, 4], [5]])
        #expect(chunks[1].startIndex == 2)
    }

    @Test
    func `Chunks accept any range-replaceable output`() {
        let string = "abcdefg"
        let chunks: ContiguousArray<Substring> = string.chunks(of: 3)
        #expect(chunks.map(String.init) == ["abc", "def", "g"])
    }

    @Test
    func `Chunks of an exact multiple have no remainder`() {
        let chunks: [ArraySlice<Int>] = [1, 2, 3, 4].chunks(of: 2)
        #expect(chunks.count == 2)
    }

    @Test
    func `Chunks of an empty collection are empty`() {
        let chunks: [ArraySlice<Int>] = [Int]().chunks(of: 3)
        #expect(chunks.isEmpty)
    }

    @Test
    func `Chunks of a non-positive size are empty`() {
        let chunks: [ArraySlice<Int>] = [1, 2, 3].chunks(of: 0)
        #expect(chunks.isEmpty)
    }

    @Test
    func `Chunked copies the chunks into arrays`() {
        #expect([1, 2, 3, 4, 5].chunked(into: 2) == [[1, 2], [3, 4], [5]])
        #expect([1, 2, 3].chunked(into: 0).isEmpty)
    }
}
