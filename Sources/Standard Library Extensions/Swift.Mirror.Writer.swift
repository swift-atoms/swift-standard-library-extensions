#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// The writer of `bytes(of:)`: the bytes not yet handed on, where they go, and what it has learned on the way.
        /// A `Swift.Mirror.Written` type writes itself through it.
        ///
        /// It names each type by its order of first appearance after the first time, and decides once per type how
        /// its values are written. An array of 256 bytes or more is written on its own, as a block that does not
        /// depend on what was written before it, and a block equal to one written before as which one that was:
        /// so what is written depends on the value alone, never on which of its arrays share storage. Sharing only
        /// saves work: storage met before is known by its address, and kept alive until the writer is done, so that
        /// no storage it remembers is freed and reused under it.
        public final class Writer {
            var bytes: [UInt8] = []
            let sink: ((borrowing RawSpan) -> Void)?
            var types: [ObjectIdentifier: Int] = [:]
            var plans: [ObjectIdentifier: Known]
            var runs: [Run: Int] = [:]
            var blocks: [[UInt8]] = []
            var contents: [Int: [Int]] = [:]
            var kept: [Any] = []
            var objects: [ObjectIdentifier]
            var lowest: Int = .max

            init(
                objects: [ObjectIdentifier] = [],
                plans: [ObjectIdentifier: Known] = [:],
                sink: ((borrowing RawSpan) -> Void)? = nil,
                capacity: Int = 1 << 16
            ) {
                self.objects = objects
                self.plans = plans
                self.sink = sink
                bytes.reserveCapacity(capacity)
            }
        }
    }

    extension Swift.Mirror.Writer {
        /// Hands the bytes so far to the sink, if there is one.
        func flush() {
            guard let sink, !bytes.isEmpty else { return }
            sink(bytes.span.bytes)
            bytes.removeAll(keepingCapacity: true)
        }

        /// A count, an index or a case's place, as eight bytes, little-endian.
        public func number(_ value: UInt64) {
            withUnsafeBytes(of: value.littleEndian) { unsafe bytes.append(contentsOf: $0) }
        }

        /// A count, an index or a case's place, which is never negative, as eight bytes.
        func number(_ value: Int) {
            number(UInt64(value))
        }

        func kind(_ kind: Kind) {
            bytes.append(kind.byte)
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
            if let known = plans[identifier] { return known.plan }
            let plan: Plan
            if _isPOD(Value.self) {
                plan = plain(value) ? .memory : .reflected
            } else if Value.self == String.self || Value.self == Substring.self || Value.self == Character.self {
                plan = .text
            } else if Mirror(reflecting: value).subjectType != Value.self {
                plan = .reflected
            } else if value is any Swift.Mirror.Written {
                plan = .written
            } else if value is any Swift.Mirror.Canonical {
                plan = .canonical
            } else if value is any Swift.Mirror.Contiguous {
                plan = .run
            } else if value is any CustomReflectable, !_typeName(Value.self, qualified: true).hasPrefix("Swift.") {
                plan = .refused
            } else {
                plan = .reflected
            }
            plans[identifier] = Known(plan: plan, order: nil)
            return plan
        }

        /// A type written through what is known of it: by name the first time, by its order after that.
        func type<Value>(of value: Value) {
            let identifier = ObjectIdentifier(Value.self)
            if let order = plans[identifier]?.order {
                bytes.append(0)
                number(order)
                return
            }
            type(Value.self)
            if let order = types[identifier], let plan = plans[identifier]?.plan {
                plans[identifier] = Known(plan: plan, order: order)
            }
        }

        /// A number in floating point, as its memory.
        public func float(_ value: Double) {
            withUnsafeBytes(of: value.bitPattern.littleEndian) { unsafe bytes.append(contentsOf: $0) }
            if bytes.count >= 1 << 16 { flush() }
        }

        /// Whether an array's elements need not be written because they were written before: never, and nothing
        /// is written. Skipping an array met again by its storage would make the bytes depend on which arrays share
        /// storage rather than on the value; `shared(_:_:)` pays for a shared array once without that.
        public func again<Element>(_ array: [Element]) -> Bool {
            false
        }

        /// An array written by `contents`, which must write what the array holds and nothing else, the same for
        /// equal arrays: a `Swift.Mirror.Written` type writes an array met often through this, so a shared array
        /// is paid for once. An array under 256 bytes of elements is written in place; a larger one on its own, as
        /// a block of what `contents` writes to the writer it is given, with types named afresh, and a block equal
        /// to one written before as which one that was. Equal arrays give equal bytes whether they share storage or
        /// not; storage met before skips `contents`. False where `contents` is.
        public func shared<Element>(_ array: [Element], _ contents: (Swift.Mirror.Writer) -> Bool) -> Bool {
            guard !Self.small(array.count, of: Element.self) else {
                kind(.inline)
                return contents(self)
            }
            let run = array.withUnsafeBufferPointer {
                unsafe Self.run(address: $0.baseAddress, count: $0.count, of: Element.self, as: [Element].self, own: true)
            }
            return block(run, keeping: array, contents)
        }

        /// Whether a value's memory holds exactly its state, every byte of it, the same for equal values in every
        /// process: an integer, a floating-point number or a truth value, a part with no stored property that holds
        /// no reference, or a structure or tuple of such parts with no byte between them. An enum is never plain:
        /// the bytes of a case's payload that a smaller case leaves unused are whatever they were.
        func plain<Value>(_ value: Value) -> Bool {
            guard _isPOD(Value.self) else { return false }
            if let known = plans[ObjectIdentifier(Value.self)] { return known.plan == .memory }
            if MemoryLayout<Value>.size <= 1 { return true }
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

        /// A value and its parts, or false where reflection cannot show it whole: what a `Swift.Mirror.Written`
        /// type writes of each of its parts.
        public func write<Value>(_ value: Value) -> Bool {
            switch plan(for: value) {
            case .memory:
                type(of: value)
                kind(.memory)
                memory(value)
                return true

            case .text:
                type(of: value)
                kind(.text)
                text(String(describing: value))
                return true

            case .run:
                type(of: value)
                guard let run = value as? any Swift.Mirror.Contiguous else { return false }
                return run.write(into: self)

            case .refused:
                return false

            case .reflected:
                return reflect(value)

            case .written:
                guard let written = value as? any Swift.Mirror.Written else { return false }
                type(of: value)
                kind(.written)
                return written.write(into: self)

            case .canonical:
                guard let canonical = value as? any Swift.Mirror.Canonical else { return false }
                type(of: value)
                return write(any: canonical.canonical)
            }
        }

        /// The elements of an array: the count and the elements, as their memory in one piece when they hold no
        /// references; in place when under 256 bytes, else as a block.
        func run<Element>(_ elements: UnsafeBufferPointer<Element>, of array: Any, as type: Any.Type) -> Bool {
            let memory: Bool
            if let first = unsafe elements.first {
                memory = plain(first) && MemoryLayout<Element>.size == MemoryLayout<Element>.stride
            } else {
                memory = false
            }
            func contents(_ writer: Swift.Mirror.Writer) -> Bool {
                writer.kind(.run)
                writer.number(elements.count)
                if memory {
                    writer.number(MemoryLayout<Element>.stride)
                    unsafe writer.bytes.append(contentsOf: UnsafeRawBufferPointer(elements))
                    return true
                }
                for index in elements.indices {
                    guard writer.write(unsafe elements[index]) else { return false }
                }
                return true
            }
            guard !Self.small(elements.count, of: Element.self) else { return contents(self) }
            let run = unsafe Self.run(address: elements.baseAddress, count: elements.count, of: Element.self, as: type, own: false)
            return block(run, keeping: array, contents)
        }

        /// Whether an array is small enough to write in place: under 256 bytes of elements, which cost less to
        /// write again than to set apart.
        static func small<Element>(_ count: Int, of element: Element.Type) -> Bool {
            count * MemoryLayout<Element>.stride < 256
        }

        /// An array's storage, to know it again by, or nil where its address may not be its own: an array of
        /// class references may be lent a copy of an Objective-C array's elements, freed when the loan ends.
        static func run<Element>(address: UnsafePointer<Element>?, count: Int, of element: Element.Type, as type: Any.Type, own: Bool) -> Run? {
            #if _runtime(_ObjC)
                guard !_isBridgedVerbatimToObjectiveC(Element.self) else { return nil }
            #endif
            return Run(address: UInt(bitPattern: address), count: count, type: ObjectIdentifier(type), own: own)
        }

        /// A writer for a part written on its own: what this one knows of types, but none named yet, the
        /// references on the way down, and no sink.
        func apart() -> Swift.Mirror.Writer {
            Swift.Mirror.Writer(
                objects: objects,
                plans: plans.mapValues { Known(plan: $0.plan, order: nil) },
                capacity: 0
            )
        }

        /// An array as a block: as which block it was when its storage was met before; else what `contents` writes
        /// to a writer apart, as which block it was when an equal block was written before, or else whole.
        /// Storage is remembered only when the block refers to no reference above it, so that its block is the
        /// same wherever it is met; it is kept alive until the writer is done.
        func block(_ run: Run?, keeping array: Any, _ contents: (Swift.Mirror.Writer) -> Bool) -> Bool {
            if let run, let index = runs[run] {
                kind(.again)
                number(index)
                return true
            }
            let part = apart()
            guard contents(part) else { return false }
            lowest = min(lowest, part.lowest)
            let block = part.bytes
            let print = Self.print(of: block)
            let index: Int
            if let earlier = self.contents[print]?.first(where: { Self.same(blocks[$0], block) }) {
                index = earlier
                kind(.again)
                number(index)
            } else {
                index = blocks.count
                blocks.append(block)
                self.contents[print, default: []].append(index)
                kind(.block)
                number(block.count)
                if let sink {
                    flush()
                    sink(block.span.bytes)
                } else {
                    bytes.append(contentsOf: block)
                }
            }
            if let run, part.lowest >= objects.count {
                runs[run] = index
                kept.append(array)
            }
            return true
        }

        /// Whether two blocks hold the same bytes, compared eight at a time.
        static func same(_ first: [UInt8], _ second: [UInt8]) -> Bool {
            guard first.count == second.count else { return false }
            return first.withUnsafeBytes { first in
                second.withUnsafeBytes { second in
                    var offset = 0
                    while offset + 8 <= first.count {
                        let left = unsafe first.loadUnaligned(fromByteOffset: offset, as: UInt64.self)
                        let right = unsafe second.loadUnaligned(fromByteOffset: offset, as: UInt64.self)
                        guard left == right else { return false }
                        offset += 8
                    }
                    while offset < first.count {
                        guard unsafe first[offset] == second[offset] else { return false }
                        offset += 1
                    }
                    return true
                }
            }
        }

        /// A block's length and some of its bytes, spread over it, mixed: equal blocks give the same, so only
        /// blocks with the same print need comparing whole.
        static func print(of block: [UInt8]) -> Int {
            var hasher = Hasher()
            hasher.combine(block.count)
            let step = Swift.max(1, block.count / 64)
            var index = 0
            while index < block.count {
                hasher.combine(block[index])
                index += step
            }
            hasher.combine(block.last)
            return hasher.finalize()
        }

        /// A value through its mirror. A value held in an existential is written as the type it holds. A case
        /// without a payload is written as its memory where that is one byte, which then holds the case alone;
        /// otherwise as its raw value, or its name, since a larger enum's memory may hold bytes another case left.
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
                    guard subject == Value.self else { return false }
                    if MemoryLayout<Value>.size <= 1 {
                        number(0)
                        memory(value)
                        return true
                    }
                    if let raw = value as? any RawRepresentable {
                        number(1)
                        return raw.written(by: self)
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
                    let member = apart()
                    guard member.write(any: child.value) else { return false }
                    lowest = min(lowest, member.lowest)
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
                    lowest = min(lowest, depth)
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
