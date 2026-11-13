#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// The writer of `bytes(of:)`: the bytes not yet handed on, where they go, and what it has learned on the way.
        ///
        /// It names each type by its order of first appearance after the first time, decides once per type how its
        /// values are written, writes an array whose storage it met before as which one it was, and keeps those
        /// arrays alive until it is done, so that no storage it remembers is freed and reused under it.
        final class Structure {
            var bytes: [UInt8] = []
            let sink: ((borrowing RawSpan) -> Void)?
            var types: [ObjectIdentifier: Int] = [:]
            var plans: [ObjectIdentifier: Plan] = [:]
            var runs: [Run: Int] = [:]
            var kept: [Any] = []
            var objects: [ObjectIdentifier]

            init(objects: [ObjectIdentifier] = [], sink: ((borrowing RawSpan) -> Void)? = nil) {
                self.objects = objects
                self.sink = sink
                bytes.reserveCapacity(1 << 16)
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
            case again = 9
        }

        /// How the values of one type are written.
        enum Plan {
            /// As their memory: the type holds no references.
            case memory
            /// As their UTF-8.
            case text
            /// As an array.
            case run
            /// Not at all: the type writes its own mirror.
            case refused
            /// Through `Mirror`.
            case reflected
            /// As the value it gives for itself.
            case canonical
        }

        /// An array's storage: where its elements lie, how many, and of what type.
        struct Run: Hashable {
            let address: UInt
            let count: Int
            let type: ObjectIdentifier
        }

        /// Hands the bytes so far to the sink, if there is one.
        func flush() {
            guard let sink, !bytes.isEmpty else { return }
            sink(bytes.span.bytes)
            bytes.removeAll(keepingCapacity: true)
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
                number(seen)
            } else {
                types[identifier] = types.count
                bytes.append(1)
                text(_typeName(type, qualified: true))
            }
        }

        /// The memory of a value, its size first.
        func memory<Value>(_ value: Value) {
            number(MemoryLayout<Value>.size)
            withUnsafeBytes(of: value) { unsafe bytes.append(contentsOf: $0) }
            if bytes.count >= 1 << 16 { flush() }
        }

        /// A value held as `Any`, written as the type it holds.
        func write(any value: Any) -> Bool {
            func opened<Value>(_ value: Value) -> Bool { write(value) }
            return _openExistential(value, do: opened)
        }

        /// How values of a type are written, decided from one of them. A type a value is held in as an existential
        /// is reflected, since what it holds varies from value to value.
        func plan<Value>(for value: Value) -> Plan {
            let identifier = ObjectIdentifier(Value.self)
            if let plan = plans[identifier] { return plan }
            let plan: Plan
            if _isPOD(Value.self) {
                plan = plain(value) ? .memory : .reflected
            } else if Value.self == String.self || Value.self == Substring.self || Value.self == Character.self {
                plan = .text
            } else if Mirror(reflecting: value).subjectType != Value.self {
                plan = .reflected
            } else if value is any Swift.Mirror.Canonical {
                plan = .canonical
            } else if value is any Swift.Mirror.Contiguous {
                plan = .run
            } else if value is any CustomReflectable, !_typeName(Value.self, qualified: true).hasPrefix("Swift.") {
                plan = .refused
            } else {
                plan = .reflected
            }
            plans[identifier] = plan
            return plan
        }

        /// Whether a value's memory holds exactly its state, every byte of it, the same for equal values in every
        /// process: an integer, a floating-point number or a truth value, a part with no stored property that holds
        /// no reference, or a structure or tuple of such parts with no byte between them. An enum is never plain:
        /// the bytes of a case's payload that a smaller case leaves unused are whatever they were.
        func plain<Value>(_ value: Value) -> Bool {
            guard _isPOD(Value.self) else { return false }
            if let plan = plans[ObjectIdentifier(Value.self)] { return plan == .memory }
            if Value.self is any BinaryInteger.Type || Value.self is any BinaryFloatingPoint.Type || Value.self == Bool.self {
                return true
            }
            let mirror = Mirror(reflecting: value)
            guard mirror.subjectType == Value.self else { return false }
            switch mirror.displayStyle {
            case .struct, .tuple, nil:
                var size = 0
                for child in mirror.children {
                    func opened<Field>(_ field: Field) -> Bool {
                        size += MemoryLayout<Field>.size
                        return plain(field)
                    }
                    guard _openExistential(child.value, do: opened) else { return false }
                }
                return size == MemoryLayout<Value>.size || mirror.children.isEmpty
            default:
                return false
            }
        }

        /// A value and its parts, or false where reflection cannot show it whole.
        func write<Value>(_ value: Value) -> Bool {
            switch plan(for: value) {
            case .memory:
                type(Value.self)
                kind(.memory)
                memory(value)
                return true

            case .text:
                type(Value.self)
                kind(.text)
                text(String(describing: value))
                return true

            case .run:
                type(Value.self)
                guard let run = value as? any Swift.Mirror.Contiguous else { return false }
                return run.write(into: self)

            case .refused:
                return false

            case .reflected:
                return reflect(value)

            case .canonical:
                guard let canonical = value as? any Swift.Mirror.Canonical else { return false }
                type(Value.self)
                return write(any: canonical.canonical)
            }
        }

        /// The elements of an array: its storage as which one it was when met before, or else the count and the
        /// elements, as their memory in one piece when they hold no references.
        func run<Element>(_ elements: UnsafeBufferPointer<Element>, of array: Any, as type: Any.Type) -> Bool {
            let address = UInt(bitPattern: elements.baseAddress)
            if again(Run(address: address, count: elements.count, type: ObjectIdentifier(type)), keeping: array) {
                return true
            }
            kind(.run)
            number(elements.count)
            if let first = unsafe elements.first, plain(first), MemoryLayout<Element>.size == MemoryLayout<Element>.stride {
                number(MemoryLayout<Element>.stride)
                flush()
                let raw = UnsafeRawBufferPointer(elements)
                if let sink {
                    sink(unsafe RawSpan(_unsafeBytes: raw))
                } else {
                    unsafe bytes.append(contentsOf: raw)
                }
                return true
            }
            for index in elements.indices {
                guard write(unsafe elements[index]) else { return false }
            }
            return true
        }

        /// Whether an array's storage was met before, written as which one it was; the first time it is
        /// remembered, and the array kept alive.
        func again(_ run: Run, keeping value: Any) -> Bool {
            guard run.count > 0 else { return false }
            if let seen = runs[run] {
                kind(.again)
                number(seen)
                return true
            }
            runs[run] = runs.count
            kept.append(value)
            return false
        }

        /// A value through its mirror. A value held in an existential is written as the type it holds.
        func reflect<Value>(_ value: Value) -> Bool {
            let mirror = Mirror(reflecting: value)
            let subject = mirror.subjectType
            if subject != Value.self, mirror.children.isEmpty, mirror.displayStyle != .collection {
                return false
            }
            type(subject)
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
                    // A case without a payload: its memory where that is one byte, which then holds the case alone;
                    // otherwise its raw value, or its name. A larger enum's memory may hold bytes another case left.
                    guard subject == Value.self else { return false }
                    if MemoryLayout<Value>.size <= 1 {
                        number(0)
                        memory(value)
                        return true
                    }
                    if let raw = value as? any RawRepresentable {
                        number(1)
                        return write(any: raw.rawValue)
                    }
                    guard !(value is any CustomStringConvertible), !(value is any CustomDebugStringConvertible),
                        !(value is any TextOutputStreamable)
                    else { return false }
                    number(2)
                    text(String(describing: value))
                    return true
                }
                number(3)
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
                let children = mirror.children
                let count = children.count
                guard count > 0 || mirror.displayStyle == .collection else { return false }
                kind(mirror.displayStyle == .collection ? .run : .fields)
                number(count)
                for child in children {
                    guard write(any: child.value) else { return false }
                }
                return true
            }
        }
    }
#endif
