import Testing

@testable import Standard_Library_Extensions

@Suite
struct `StringProtocol.range(of:) - Basic Matching` {

    @Test
    func `Find substring in middle`() {
        let result = "Hello World".range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Find substring at start`() {
        let result = "Hello World".range(of: "Hello")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "Hello")
        }
    }

    @Test
    func `Find substring at end`() {
        let result = "Hello World".range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Find single character`() {
        let result = "test".range(of: "s")
        #expect(result != nil)
        if let range = result {
            #expect("test"[range] == "s")
        }
    }

    @Test
    func `Not found returns nil`() {
        #expect("Hello World".range(of: "xyz") == nil)
    }
}

@Suite
struct `StringProtocol.range(of:) - Edge Cases` {

    @Test
    func `Empty search string returns empty range at start`() {
        let result = "test".range(of: "")
        #expect(result != nil)
        if let range = result {
            #expect(range.isEmpty)
            #expect(range.lowerBound == "test".startIndex)
        }
    }

    @Test
    func `Empty source string returns nil for non-empty search`() {
        #expect("".range(of: "test") == nil)
    }

    @Test
    func `Search string longer than source returns nil`() {
        #expect("abc".range(of: "abcdef") == nil)
    }

    @Test
    func `Exact match returns full range`() {
        let result = "test".range(of: "test")
        #expect(result != nil)
        if let range = result {
            #expect("test"[range] == "test")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Multiple Occurrences` {

    @Test
    func `Returns first occurrence`() {
        let result = "test test test".range(of: "test")
        #expect(result != nil)
        if let range = result {

            #expect(range.lowerBound == "test test test".startIndex)
        }
    }

    @Test
    func `Find repeated pattern`() {
        let result = "aaabbbaaaccc".range(of: "aaa")
        #expect(result != nil)
        if let range = result {
            #expect("aaabbbaaaccc"[range] == "aaa")
            #expect(range.lowerBound == "aaabbbaaaccc".startIndex)
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Substring Support` {

    @Test
    func `Works with Substring as source`() {
        let string = "Hello World Test"
        let substring = string[string.startIndex..<string.index(string.startIndex, offsetBy: 11)]

        let result = substring.range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect(substring[range] == "World")
        }
    }

    @Test
    func `Works with Substring as search pattern`() {
        let pattern = "World Test"
        let subPattern = pattern[
            pattern.startIndex..<pattern.index(pattern.startIndex, offsetBy: 5)
        ]

        let result = "Hello World".range(of: subPattern)
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Zero-copy Substring search`() {
        let large = "prefix_Hello World_suffix"
        let start = large.index(large.startIndex, offsetBy: 7)
        let end = large.index(start, offsetBy: 11)
        let sub = large[start..<end]

        #expect(type(of: sub) == Substring.self)

        let result = sub.range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect(sub[range] == "World")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Special Characters` {

    @Test
    func `Find unicode characters`() {
        let result = "Hello 🌍 World".range(of: "🌍")
        #expect(result != nil)
        if let range = result {
            #expect("Hello 🌍 World"[range] == "🌍")
        }
    }

    @Test
    func `Find string with spaces`() {
        let result = "This is a test".range(of: "is a")
        #expect(result != nil)
        if let range = result {
            #expect("This is a test"[range] == "is a")
        }
    }

    @Test
    func `Find punctuation`() {
        let result = "Hello, World!".range(of: ", ")
        #expect(result != nil)
        if let range = result {
            #expect("Hello, World!"[range] == ", ")
        }
    }

    @Test
    func `Find newline`() {
        let result = "Line1\nLine2".range(of: "\n")
        #expect(result != nil)
        if let range = result {
            #expect("Line1\nLine2"[range] == "\n")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Case Sensitivity` {

    @Test
    func `Case sensitive search`() {
        #expect("Hello World".range(of: "world") == nil)
        #expect("Hello World".range(of: "World") != nil)
    }

    @Test
    func `Exact case required`() {
        #expect("TEST".range(of: "test") == nil)
        #expect("TEST".range(of: "TEST") != nil)
    }
}

@Suite
struct `StringProtocol.range(of:) - Backtracking` {

    @Test
    func `Partial prefix match requires backtrack`() {

        let haystack = "aaab"
        let result = haystack.range(of: "aab")
        #expect(result != nil)
        if let range = result {
            #expect(haystack[range] == "aab")
            #expect(haystack.distance(from: haystack.startIndex, to: range.lowerBound) == 1)
        }
    }

    @Test
    func `Overlapping prefix returns first full match`() {

        let haystack = "ababab"
        let result = haystack.range(of: "abab")
        #expect(result != nil)
        if let range = result {
            #expect(haystack[range] == "abab")
            #expect(range.lowerBound == haystack.startIndex)
        }
    }

    @Test
    func `ASCII pattern inside Unicode haystack`() {
        let haystack = "prefix 🌍 warning: foo"
        let result = haystack.range(of: "warning: ")
        #expect(result != nil)
        if let range = result {
            #expect(haystack[range] == "warning: ")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Byte-Literal Semantics` {

    @Test
    func `Precomposed does not match decomposed`() {

        let precomposed = "caf\u{00E9}"
        let decomposed = "cafe\u{0301}"

        #expect(precomposed.range(of: decomposed) == nil)
        #expect(decomposed.range(of: precomposed) == nil)

        #expect(precomposed.range(of: precomposed) != nil)
        #expect(decomposed.range(of: decomposed) != nil)
    }
}

@Suite
struct `StringProtocol.range(of:) - Multi-Byte UTF-8 Widths` {

    @Test
    func `Find two-byte UTF-8 scalar`() {
        let haystack = "café"
        let result = haystack.range(of: "é")
        #expect(result != nil)
        if let range = result {
            #expect(haystack[range] == "é")
        }
    }

    @Test
    func `Find three-byte UTF-8 scalar`() {
        let haystack = "hello 世界"
        let result = haystack.range(of: "世")
        #expect(result != nil)
        if let range = result {
            #expect(haystack[range] == "世")
        }
    }
}
