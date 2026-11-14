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
        let forward = Dictionary(uniqueKeysWithValues: (0..<64).map { ("key \($0)", $0) })
        let backward = Dictionary(uniqueKeysWithValues: (0..<64).reversed().map { ("key \($0)", $0) })
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
    func `An array met again is written once, and pieces handed on are the bytes`() throws {
        let shared = (0..<1000).map { Point(x: Double($0), y: 1) }
        let copy = shared.map { $0 }
        let once = try #require(Mirror.bytes(of: Pair(first: shared, second: shared)))
        #expect(once.count < 17_000)
        #expect(Mirror.bytes(of: Pair(first: shared, second: copy)) == once)
        for value in [Self.named(.group([.circle(1), .empty], "g")), Self.named(.group(Array(repeating: .circle(1), count: 40), "g"))] {
            var pieces: [UInt8] = []
            let whole = Mirror.bytes(of: value) { piece in
                piece.withUnsafeBytes { unsafe pieces.append(contentsOf: $0) }
            }
            #expect(whole)
            #expect(pieces == Mirror.bytes(of: value))
        }
        var pieces: [UInt8] = []
        #expect(Mirror.bytes(of: Pair(first: shared, second: copy)) { piece in piece.withUnsafeBytes { unsafe pieces.append(contentsOf: $0) } })
        #expect(pieces == once)
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
    struct Padded {
        var a: UInt8
        var b: UInt64
    }

    struct Packed {
        var a: UInt64
        var b: UInt8
    }

    enum Choice {
        case small(UInt8)
        case large(UInt64, UInt64)
        case none
    }

    @Test
    func `Only memory that holds exactly the state is written as memory`() {
        let structure = Swift.Mirror.Writer()
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
    enum Mode: CustomStringConvertible {
        case first, second
        var description: String { "mode" }
    }

    enum Wrapped {
        case value(Mode)
        case other(UInt64)
        case nothing
    }

    @Test
    func `A case without a payload is told apart however it describes itself`() {
        #expect(Mirror.bytes(of: Mode.first) != Mirror.bytes(of: Mode.second))
        #expect(Mirror.bytes(of: Wrapped.value(.first)) != Mirror.bytes(of: Wrapped.value(.second)))
        #expect(Mirror.bytes(of: Wrapped.nothing) != nil)
        #expect(Mirror.bytes(of: Wrapped.nothing) != Mirror.bytes(of: Wrapped.other(0)))
    }
}

extension `Mirror - Extensions` {
    enum Stroke: Swift.Mirror.Written {
        case line([Point], Double)
        case none

        func write(into writer: Swift.Mirror.Writer) -> Bool {
            switch self {
            case .line(let points, let width):
                writer.number(0)
                writer.float(width)
                return writer.shared(points) { writer in
                    writer.number(points.count)
                    for point in points {
                        guard writer.write(point) else { return false }
                    }
                    return true
                }
            case .none:
                writer.number(1)
                return true
            }
        }
    }

    @Test
    func `A written type is written as it writes itself`() {
        let points = (0..<100).map { Point(x: Double($0), y: 2) }
        #expect(Mirror.bytes(of: Stroke.line(points, 1)) == Mirror.bytes(of: Stroke.line(points.map { $0 }, 1)))
        #expect(Mirror.bytes(of: Stroke.line(points, 1)) != Mirror.bytes(of: Stroke.line(points, 2)))
        #expect(Mirror.bytes(of: Stroke.line(points, 1)) != Mirror.bytes(of: Stroke.none))
        #expect(Mirror.bytes(of: [Stroke.line(points, 1), .line(points, 1)]) == Mirror.bytes(of: [Stroke.line(points, 1), .line(points.map { $0 }, 1)]))
        #expect(Mirror.bytes(of: [Stroke.line(points, 1), .line(points, 1)])!.count < Mirror.bytes(of: [Stroke.line(points, 1), .line(points.map { Point(x: $0.x, y: 3) }, 1)])!.count)
    }
}

extension `Mirror - Extensions` {
    struct Sprite {
        var x: Double
        var y: Double
        var radius: Double
    }

    struct Picture {
        var elements: [Element]
    }

    indirect enum Element {
        case sprites([Sprite])
        case group(Picture)
    }

    struct Drawn: Swift.Mirror.Written {
        var elements: [Sprite]

        func write(into writer: Swift.Mirror.Writer) -> Bool {
            writer.shared(elements) { writer in
                writer.number(UInt64(elements.count))
                for sprite in elements {
                    writer.float(sprite.x)
                    writer.float(sprite.y)
                    writer.float(sprite.radius)
                }
                return true
            }
        }
    }

    static let sprites = (0..<100).map { Sprite(x: Double($0) / 2, y: 40 - Double($0) / 4, radius: 2) }

    @Test
    func `Equal values give equal bytes whether an array is held twice or copied`() {
        let shared = Self.sprites
        let fresh = Self.sprites.map { $0 }
        let sharing = Picture(elements: [.sprites(shared), .sprites(shared)])
        let apart = Picture(elements: [.sprites(shared), .sprites(fresh)])
        #expect(Mirror.bytes(of: sharing) != nil)
        #expect(Mirror.bytes(of: sharing) == Mirror.bytes(of: apart))
        #expect(Mirror.bytes(of: [Drawn(elements: shared), Drawn(elements: shared)]) == Mirror.bytes(of: [Drawn(elements: shared), Drawn(elements: fresh)]))
    }

    @Test
    func `Equal values give equal bytes whether a nested value is held twice or copied`() {
        let inner = Picture(elements: Self.sprites.map { Element.sprites([$0]) })
        let copy = Picture(elements: inner.elements.map { $0 })
        let nested = Picture(elements: [.group(inner), .group(inner)])
        let unshared = Picture(elements: [.group(inner), .group(copy)])
        #expect(Mirror.bytes(of: nested) != nil)
        #expect(Mirror.bytes(of: nested) == Mirror.bytes(of: unshared))
        let deep = Picture(elements: Self.sprites.map { Element.sprites([$0].map { $0 }) })
        #expect(Mirror.bytes(of: Picture(elements: [.group(inner), .group(deep)])) == Mirror.bytes(of: nested))
    }

    @Test
    func `Unequal arrays give different bytes, held twice or not`() {
        let base = (0..<1000).map { Point(x: Double($0), y: 1) }
        var middle = base
        middle[517].y = 2
        let longer = base + [Point(x: 0, y: 0)]
        let values: [[[Point]]?] = [
            [base, base], [base, middle], [middle, base], [base, longer], [base], [base, [], base], [base, base, []],
            [], nil, [[]],
        ]
        let bytes = values.map { Mirror.bytes(of: $0) }
        #expect(Set(bytes.compactMap { $0 }).count == values.count)
        let nestings: [[[Int]]] = [[[1, 2], [3]], [[1], [2, 3]], [[1, 2, 3]], [[1, 2, 3], []]]
        #expect(Set(nestings.compactMap { Mirror.bytes(of: $0) }).count == nestings.count)
        let large = Array(0..<100)
        let deeper: [[[Int]]] = [[large, large], [large + large], [large, [], large], [large], [large, large.reversed()]]
        #expect(Set(deeper.compactMap { Mirror.bytes(of: $0) }).count == deeper.count)
        let drawn = [Drawn(elements: Self.sprites), Drawn(elements: Self.sprites.dropLast() + [Sprite(x: 0, y: 0, radius: 3)])]
        #expect(Mirror.bytes(of: [drawn[0], drawn[0]]) != Mirror.bytes(of: drawn))
    }

    @Test
    func `A block does not depend on what was written before it`() {
        let marks: [Choice] = (0..<100).map { $0 % 2 == 0 ? .small(UInt8($0)) : .none }
        let alone = Swift.Mirror.Writer()
        #expect(alone.write(marks))
        let after = Swift.Mirror.Writer()
        #expect(after.write((0..<100).map { Choice.large(UInt64($0), 1) }))
        #expect(after.write(marks))
        #expect(alone.blocks.count == 1)
        #expect(after.blocks.count == 2)
        #expect(after.blocks.last == alone.blocks.last)
    }

    struct Fresh: Swift.Mirror.Written {
        var values: [Int]

        func write(into writer: Swift.Mirror.Writer) -> Bool {
            for value in values {
                guard Self.write(Array(repeating: value, count: 64), into: writer) else { return false }
            }
            return true
        }

        static func write(_ array: [Int], into writer: Swift.Mirror.Writer) -> Bool {
            writer.shared(array) { writer in
                for value in array { writer.number(UInt64(value)) }
                return true
            }
        }
    }

    @Test
    func `Storage freed and reused while writing is not taken for an array met before`() {
        let fresh = Swift.Mirror.Writer()
        #expect(Fresh(values: [1, 2, 3, 1]).write(into: fresh))
        let arrays = [1, 2, 3, 1].map { Array(repeating: $0, count: 64) }
        let held = Swift.Mirror.Writer()
        for array in arrays {
            #expect(Fresh.write(array, into: held))
        }
        #expect(fresh.bytes == held.bytes)
        #expect(fresh.blocks.count == 3)
        #expect(!Swift.Mirror.Writer().again(arrays[0]))
    }
}
