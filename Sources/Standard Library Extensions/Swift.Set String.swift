extension Swift.Set<String> {

    @inlinable
    public static var swift: `Swift` {
        .init()
    }

    public struct `Swift` {
        @usableFromInline
        internal init() {}
    }
}

extension Swift.Set<String>.`Swift` {

    /// The words The Swift Programming Language reserves, which an identifier
    /// must escape with backticks: declaration, statement, expression and type
    /// keywords.
    public static let keywords: Set<String> = [
        // Declarations
        "associatedtype", "borrowing", "class", "consuming", "deinit", "enum",
        "extension", "fileprivate", "func", "import", "init", "inout", "internal",
        "let", "nonisolated", "open", "operator", "private", "precedencegroup",
        "protocol", "public", "rethrows", "static", "struct", "subscript",
        "typealias", "var",
        // Statements
        "break", "case", "catch", "continue", "default", "defer", "do", "else",
        "fallthrough", "for", "guard", "if", "in", "repeat", "return", "throw",
        "switch", "where", "while",
        // Expressions and types
        "Any", "as", "await", "false", "is", "nil", "self", "Self", "super",
        "throws", "true", "try",
    ]

    @inlinable
    public func escape(_ identifier: String) -> String {
        Set<String>.Swift.keywords.contains(identifier) ? "`\(identifier)`" : identifier
    }
}
