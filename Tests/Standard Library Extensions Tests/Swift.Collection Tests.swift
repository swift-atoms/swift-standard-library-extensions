import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Collection Element Access` {

    @Test
    func `Element at returns element for valid index`() {
        let array = [1, 2, 3, 4, 5]
        #expect(array.element(at: 0) == 1)
        #expect(array.element(at: 2) == 3)
        #expect(array.element(at: 4) == 5)
    }

    @Test
    func `Element at with string`() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 1)
        #expect(string.element(at: index) == "e")
        #expect(string.element(at: string.startIndex) == "H")
    }

    @Test
    func `Element at with dictionary values`() {
        let dict = ["a": 1, "b": 2, "c": 3]
        let values = Array(dict.values.sorted())
        #expect(values.element(at: 0) == 1)
        #expect(values.element(at: 1) == 2)
        #expect(values.element(at: 2) == 3)
    }

    @Test
    func `Element at returns nil for out of bounds positive index`() {
        let array = [1, 2, 3]
        #expect(array.element(at: 10) == nil)
        #expect(array.element(at: 100) == nil)
    }

    @Test
    func `Element at returns nil for negative index`() {
        let array = [1, 2, 3]
        #expect(array.element(at: -1) == nil)
        #expect(array.element(at: -10) == nil)
    }

    @Test
    func `Element at on empty collection`() {
        let empty: [Int] = []
        #expect(empty.element(at: 0) == nil)
        #expect(empty.element(at: 1) == nil)
    }

    @Test
    func `Element at with ArraySlice`() {
        let array = [1, 2, 3, 4, 5]
        let slice = array[1...3]
        #expect(slice.element(at: 1) == 2)
        #expect(slice.element(at: 2) == 3)
        #expect(slice.element(at: 3) == 4)
        #expect(slice.element(at: 0) == nil)
        #expect(slice.element(at: 4) == nil)
    }

    @Test
    func `Element at with ContiguousArray`() {
        let array: ContiguousArray = [10, 20, 30]
        #expect(array.element(at: 0) == 10)
        #expect(array.element(at: 2) == 30)
        #expect(array.element(at: 3) == nil)
    }

    @Test
    func `Natural transformation preserves structure`() {

        let collection = [1, 2, 3]

        let validResult = collection.element(at: 1)
        #expect(validResult != nil)
        #expect(validResult == collection[1])

        let invalidResult = collection.element(at: 10)
        #expect(invalidResult == nil)
    }

    @Test
    func `Totality property - never traps`() {
        let array = [1, 2, 3]

        _ = array.element(at: -100)
        _ = array.element(at: 100)
        _ = array.element(at: Int.max)

        #expect(Bool(true))
    }

    @Test
    func `Elements in returns the slice for a valid range`() {
        let string = "Hello"
        let range = string.index(after: string.startIndex)..<string.endIndex
        #expect(string.elements(in: range) == "ello")
    }

    @Test
    func `Elements in returns nil for an out of bounds range`() {
        let slice = [1, 2, 3, 4, 5][1...3]
        #expect(slice.elements(in: 1..<4) == [2, 3, 4])
        #expect(slice.elements(in: 0..<2) == nil)
        #expect(slice.elements(in: 2..<5) == nil)
    }

    @Test
    func `Array elements in a half-open range`() {
        let array = [1, 2, 3, 4, 5]
        #expect(array.elements(in: 1..<3) == [2, 3])
        #expect(array.elements(in: 0..<5) == [1, 2, 3, 4, 5])
        #expect(array.elements(in: 2..<2) == [])
        #expect(array.elements(in: -1..<2) == nil)
        #expect(array.elements(in: 3..<6) == nil)
    }

    @Test
    func `Array elements in a closed range`() {
        let array = [1, 2, 3, 4, 5]
        #expect(array.elements(in: 1...3) == [2, 3, 4])
        #expect(array.elements(in: 0...4) == [1, 2, 3, 4, 5])
        #expect(array.elements(in: -1...2) == nil)
        #expect(array.elements(in: 3...5) == nil)
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
