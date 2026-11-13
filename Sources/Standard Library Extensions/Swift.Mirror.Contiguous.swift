#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// An array whose elements, when they hold no references, are written as their memory in one piece
        /// rather than one by one through `Mirror`.
        protocol Contiguous {
            /// The count and the elements' memory, or false when the elements hold references.
            func write(into structure: Swift.Mirror.Structure) -> Bool
        }
    }

    extension Swift.Array: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            guard _isPOD(Element.self) else { return false }
            structure.kind(.run)
            structure.number(count)
            structure.number(MemoryLayout<Element>.stride)
            withUnsafeBytes { unsafe structure.bytes.append(contentsOf: $0) }
            return true
        }
    }

    extension Swift.ContiguousArray: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            guard _isPOD(Element.self) else { return false }
            structure.kind(.run)
            structure.number(count)
            structure.number(MemoryLayout<Element>.stride)
            withUnsafeBytes { unsafe structure.bytes.append(contentsOf: $0) }
            return true
        }
    }

    extension Swift.ArraySlice: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            guard _isPOD(Element.self) else { return false }
            structure.kind(.run)
            structure.number(count)
            structure.number(MemoryLayout<Element>.stride)
            withUnsafeBytes { unsafe structure.bytes.append(contentsOf: $0) }
            return true
        }
    }
#endif
