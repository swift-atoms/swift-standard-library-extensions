#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// The writer of `bytes(of:)`: the bytes so far, the types named so far by the order they were first
        /// met, and the objects on the way down from the value.
        final class Structure {
            var bytes: [UInt8] = []
            var types: [ObjectIdentifier: UInt64] = [:]
            var objects: [ObjectIdentifier]

            init(objects: [ObjectIdentifier] = []) {
                self.objects = objects
            }
        }
    }

    extension Swift.Mirror.Structure {
        /// What follows a part's type.
        enum Kind: UInt8 {
            case memory = 0
            case text = 1
            case run = 2
            case optional = 3
            case choice = 4
            case unordered = 5
            case object = 6
            case cycle = 7
            case fields = 8
        }

        func number(_ value: Int) {
            let wide = UInt64(value).littleEndian
            withUnsafeBytes(of: wide) { unsafe bytes.append(contentsOf: $0) }
        }

        func kind(_ kind: Kind) {
            bytes.append(kind.rawValue)
        }

        func text(_ text: String) {
            let utf8 = text.utf8
            number(utf8.count)
            bytes.append(contentsOf: utf8)
        }

        /// A type by its name the first time it is met, and by the order it was first met after that.
        func type(_ type: Any.Type) {
            let identifier = ObjectIdentifier(type)
            if let seen = types[identifier] {
                bytes.append(0)
                number(Int(seen))
            } else {
                types[identifier] = UInt64(types.count)
                bytes.append(1)
                text(_typeName(type, qualified: true))
            }
        }

        /// The memory of a value, its size first.
        func memory<Value>(_ value: Value) {
            number(MemoryLayout<Value>.size)
            withUnsafeBytes(of: value) { unsafe bytes.append(contentsOf: $0) }
        }

        /// A value held as `Any`, written as the type it holds.
        func write(any value: Any) -> Bool {
            func opened<Value>(_ value: Value) -> Bool { write(value) }
            return _openExistential(value, do: opened)
        }

        /// A dynamic cast, which looks through the existential that holds a value.
        static func cast<Value, Target>(_ value: Value, to target: Target.Type) -> Target? {
            value as? Target
        }

        /// A value and its parts, or false where reflection cannot show it whole. A value held in an existential
        /// is written as the type it holds, through its mirror.
        func write<Value>(_ value: Value) -> Bool {
            if _isPOD(Value.self) {
                type(Value.self)
                kind(.memory)
                memory(value)
                return true
            }
            let mirror = Mirror(reflecting: value)
            let subject = mirror.subjectType
            let held = subject != Value.self
            type(subject)
            if subject == String.self || subject == Substring.self || subject == Character.self {
                kind(.text)
                text(String(describing: value))
                return true
            }
            if let run = value as? any Swift.Mirror.Contiguous, run.write(into: self) {
                return true
            }
            if value is any CustomReflectable, !_typeName(subject, qualified: true).hasPrefix("Swift.") {
                return false
            }
            if held, mirror.children.isEmpty, mirror.displayStyle != .collection {
                return false
            }
            switch mirror.displayStyle {
            case .optional:
                kind(.optional)
                guard let child = mirror.children.first else {
                    number(0)
                    return true
                }
                number(1)
                return write(any: child.value)

            case .enum:
                kind(.choice)
                guard let child = mirror.children.first else {
                    number(0)
                    memory(value)
                    return true
                }
                number(1)
                text(child.label ?? "")
                return write(any: child.value)

            case .dictionary, .set:
                kind(.unordered)
                var members: [[UInt8]] = []
                for child in mirror.children {
                    let member = Swift.Mirror.Structure(objects: objects)
                    guard member.write(any: child.value) else { return false }
                    members.append(member.bytes)
                }
                members.sort { $0.lexicographicallyPrecedes($1) }
                number(members.count)
                for member in members {
                    number(member.count)
                    bytes.append(contentsOf: member)
                }
                return true

            case .class:
                let identifier = ObjectIdentifier(value as AnyObject)
                if let depth = objects.lastIndex(of: identifier) {
                    kind(.cycle)
                    number(objects.count - depth)
                    return true
                }
                var children: [Mirror.Child] = []
                var level: Mirror? = mirror
                while let current = level {
                    children.append(contentsOf: current.children)
                    level = current.superclassMirror
                }
                guard !children.isEmpty else { return false }
                objects.append(identifier)
                defer { objects.removeLast() }
                kind(.object)
                number(children.count)
                for child in children {
                    guard write(any: child.value) else { return false }
                }
                return true

            default:
                let children = Array(mirror.children)
                guard !children.isEmpty || mirror.displayStyle == .collection else { return false }
                kind(mirror.displayStyle == .collection ? .run : .fields)
                number(children.count)
                for child in children {
                    guard write(any: child.value) else { return false }
                }
                return true
            }
        }
    }
#endif
