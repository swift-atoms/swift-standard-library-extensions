import Testing

@testable import Standard_Library_Extensions

@Suite
struct `Mirror - Extensions` {
    struct Point: Equatable {
        var x: Double
        var y: Double
    }

    struct Named {
        var name: String
        var points: [Point]
        var tags: Set<String>
        var weights: [String: Int]
        var shape: Shape?
    }

    indirect enum Shape {
        case nothing
        case empty
        case circle(Double)
        case square(Double)
        case group([Shape], String)
    }

    protocol Mark {}
    struct Dot: Mark { var size: Double }
    struct Dash: Mark { var size: Double }
    struct Marked { var mark: any Mark }

    struct Holding { var action: @Sendable () -> Void }

    struct Hidden: CustomReflectable {
        var secret: String
        var customMirror: Mirror { Mirror(self, children: []) }
    }

    final class Node {
        var value: Int
        var next: Node?
        init(_ value: Int) { self.value = value }
    }

    static func named(_ shape: Shape?) -> Named {
        Named(
            name: "piece",
            points: [Point(x: 1, y: 2), Point(x: 3, y: 4)],
            tags: ["a", "b", "c"],
            weights: ["one": 1, "two": 2],
            shape: shape
        )
    }

    @Test
    func `Equal values give equal bytes`() {
        let first = Mirror.bytes(of: Self.named(.group([.circle(1), .empty], "g")))
        let second = Mirror.bytes(of: Self.named(.group([.circle(1), .empty], "g")))
        #expect(first != nil)
        #expect(first == second)
    }

    @Test
    func `A change anywhere changes the bytes`() {
        let base = Self.named(.circle(1))
        var moved = base
        moved.points[1].y = 4.5
        var renamed = base
        renamed.name = "piecf"
        var tagged = base
        tagged.tags.insert("d")
        var weighed = base
        weighed.weights["two"] = 3
        let all = [base, moved, renamed, tagged, weighed].map { Mirror.bytes(of: $0) }
        #expect(Set(all.compactMap { $0 }).count == all.count)
    }

    @Test
    func `Cases are told apart with and without a payload`() {
        let cases: [Shape?] = [nil, .nothing, .empty, .circle(2), .square(2), .group([], ""), .group([.empty], "")]
        let bytes = cases.map { Mirror.bytes(of: $0) }
        #expect(Set(bytes.compactMap { $0 }).count == cases.count)
    }

    @Test
    func `Members of a set or dictionary are written in their own order, not the hashing's`() {
        var forward: [String: Int] = [:]
        for index in 0..<64 { forward["key \(index)"] = index }
        var backward: [String: Int] = [:]
        for index in (0..<64).reversed() { backward["key \(index)"] = index }
        #expect(Mirror.bytes(of: forward) == Mirror.bytes(of: backward))
        let up = Set((0..<64).map { "member \($0)" })
        let down = Set((0..<64).reversed().map { "member \($0)" })
        #expect(Mirror.bytes(of: up) == Mirror.bytes(of: down))
    }

    @Test
    func `The bytes are those of another process`() {
        // Written by an earlier run: a set of strings depends on the process's hashing seed, and an array of
        // plain values is its memory.
        let bytes = Mirror.bytes(of: (Set(["b", "a"]), [UInt16(1), 2]))
        let expected: [UInt8] = [
            1, 52, 0, 0, 0, 0, 0, 0, 0, 40, 83, 119, 105, 102, 116, 46, 83, 101, 116, 60, 83, 119, 105, 102, 116, 46,
            83, 116, 114, 105, 110, 103, 62, 44, 32, 83, 119, 105, 102, 116, 46, 65, 114, 114, 97, 121, 60, 83, 119,
            105, 102, 116, 46, 85, 73, 110, 116, 49, 54, 62, 41, 8, 2, 0, 0, 0, 0, 0, 0, 0, 1, 23, 0, 0, 0, 0, 0, 0,
            0, 83, 119, 105, 102, 116, 46, 83, 101, 116, 60, 83, 119, 105, 102, 116, 46, 83, 116, 114, 105, 110, 103,
            62, 5, 2, 0, 0, 0, 0, 0, 0, 0, 31, 0, 0, 0, 0, 0, 0, 0, 1, 12, 0, 0, 0, 0, 0, 0, 0, 83, 119, 105, 102,
            116, 46, 83, 116, 114, 105, 110, 103, 1, 1, 0, 0, 0, 0, 0, 0, 0, 97, 31, 0, 0, 0, 0, 0, 0, 0, 1, 12, 0, 0,
            0, 0, 0, 0, 0, 83, 119, 105, 102, 116, 46, 83, 116, 114, 105, 110, 103, 1, 1, 0, 0, 0, 0, 0, 0, 0, 98, 1,
            25, 0, 0, 0, 0, 0, 0, 0, 83, 119, 105, 102, 116, 46, 65, 114, 114, 97, 121, 60, 83, 119, 105, 102, 116,
            46, 85, 73, 110, 116, 49, 54, 62, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0,
        ]
        #expect(bytes == expected)
    }

    @Test
    func `Values of different types holding the same fields differ`() {
        #expect(Mirror.bytes(of: Marked(mark: Dot(size: 1))) != Mirror.bytes(of: Marked(mark: Dash(size: 1))))
        #expect(Mirror.bytes(of: Marked(mark: Dot(size: 1))) == Mirror.bytes(of: Marked(mark: Dot(size: 1))))
    }

    @Test
    func `A function or a mirror of its own gives nil`() {
        #expect(Mirror.bytes(of: Holding(action: {})) == nil)
        #expect(Mirror.bytes(of: Hidden(secret: "one")) == nil)
    }

    @Test
    func `A cycle of references ends`() {
        let first = Node(1)
        let second = Node(2)
        first.next = second
        second.next = first
        let bytes = Mirror.bytes(of: first)
        #expect(bytes != nil)
        second.value = 3
        #expect(Mirror.bytes(of: first) != bytes)
        first.next = nil
        second.next = nil
    }
}

extension `Mirror - Extensions` {
    struct Pair {
        var first: [Point]
        var second: [Point]
    }

    @Test
    func `An array met again is written as which one it was, and pieces handed on are the bytes`() throws {
        let shared = (0..<1000).map { Point(x: Double($0), y: 1) }
        let copy = shared.map { $0 }
        let once = try #require(Mirror.bytes(of: Pair(first: shared, second: shared)))
        let twice = try #require(Mirror.bytes(of: Pair(first: shared, second: copy)))
        #expect(once.count < twice.count - 15_000)
        #expect(Mirror.bytes(of: Pair(first: shared, second: shared)) == once)
        let named = Self.named(.group([.circle(1), .empty], "g"))
        var pieces: [UInt8] = []
        let whole = Mirror.bytes(of: named) { piece in
            piece.withUnsafeBytes { unsafe pieces.append(contentsOf: $0) }
        }
        #expect(whole)
        #expect(pieces == Mirror.bytes(of: named))
        #expect(!Mirror.bytes(of: Holding(action: {})) { _ in })
    }
}

extension `Mirror - Extensions` {
    struct Cached: Swift.Mirror.Canonical {
        var name: String
        var hash: Int
        var canonical: Any { name }
    }

    @Test
    func `A canonical type is written as the value it gives for itself`() {
        #expect(Mirror.bytes(of: Cached(name: "a", hash: 1)) == Mirror.bytes(of: Cached(name: "a", hash: 2)))
        #expect(Mirror.bytes(of: Cached(name: "a", hash: 1)) != Mirror.bytes(of: Cached(name: "b", hash: 1)))
        #expect(Mirror(reflecting: Cached(name: "a", hash: 1)).children.map(\.label) == ["name", "hash"])
    }
}

extension `Mirror - Extensions` {
    struct Padded { var a: UInt8; var b: UInt64 }
    struct Packed { var a: UInt64; var b: UInt8 }
    enum Choice { case small(UInt8), large(UInt64, UInt64), none }

    @Test
    func `Only memory that holds exactly the state is written as memory`() {
        let structure = Swift.Mirror.Structure()
        #expect(structure.plain(Point(x: 1, y: 2)))
        #expect(structure.plain(Packed(a: 1, b: 2)))
        #expect(!structure.plain(Padded(a: 1, b: 2)))
        #expect(!structure.plain(Choice.small(1)))
        #expect(!structure.plain(Double?.some(1)))
        let choices: [Choice] = [.small(1), .large(2, 3), .none]
        #expect(Mirror.bytes(of: choices) == Mirror.bytes(of: [Choice.small(1), .large(2, 3), .none]))
        #expect(Mirror.bytes(of: [Choice.none]) != Mirror.bytes(of: [Choice.small(0)]))
    }
}

extension `Mirror - Extensions` {
    enum Mode: CustomStringConvertible { case first, second; var description: String { "mode" } }
    enum Wrapped { case value(Mode), other(UInt64), nothing }

    @Test
    func `A case without a payload is told apart however it describes itself`() {
        #expect(Mirror.bytes(of: Mode.first) != Mirror.bytes(of: Mode.second))
        #expect(Mirror.bytes(of: Wrapped.value(.first)) != Mirror.bytes(of: Wrapped.value(.second)))
        #expect(Mirror.bytes(of: Wrapped.nothing) != nil)
        #expect(Mirror.bytes(of: Wrapped.nothing) != Mirror.bytes(of: Wrapped.other(0)))
    }
}
