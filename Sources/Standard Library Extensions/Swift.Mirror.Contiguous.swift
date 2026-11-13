#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// An array, written through its storage rather than one element at a time through `Mirror`.
        protocol Contiguous {
            func write(into structure: Swift.Mirror.Structure) -> Bool
        }
    }

    extension Swift.Array: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            withUnsafeBufferPointer { unsafe structure.run($0, of: self, as: Self.self) }
        }
    }

    extension Swift.ContiguousArray: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            withUnsafeBufferPointer { unsafe structure.run($0, of: self, as: Self.self) }
        }
    }

    extension Swift.ArraySlice: Swift.Mirror.Contiguous {
        func write(into structure: Swift.Mirror.Structure) -> Bool {
            withUnsafeBufferPointer { unsafe structure.run($0, of: self, as: Self.self) }
        }
    }
#endif
