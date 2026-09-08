extension Set<String> {

    @inlinable
    public static var swift: `Swift` {
        .init()
    }

    public struct `Swift` {
        @usableFromInline
        internal init() {}
    }
}

extension Set<String>.`Swift` {

    public static let keywords: Set<String> = [
        "as", "break", "case", "catch", "class", "continue", "default", "defer",
        "do", "else", "enum", "extension", "fallthrough", "false", "fileprivate",
        "for", "func", "guard", "if", "import", "in", "init", "inout", "internal",
        "is", "let", "nil", "operator", "private", "protocol", "public", "repeat",
        "return", "self", "Self", "static", "struct", "subscript", "super", "switch",
        "throw", "throws", "true", "try", "typealias", "var", "where", "while",
    ]

    @inlinable
    public func escape(_ identifier: String) -> String {
        Set<String>.Swift.keywords.contains(identifier) ? "`\(identifier)`" : identifier
    }
}
