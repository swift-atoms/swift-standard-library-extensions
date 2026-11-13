#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// A type that writes its own structure for `bytes(of:)`, where reflection would be too slow: each stored
        /// property, through the writer's `write(_:)`, `number(_:)`, `float(_:)` and `again(_:)`, and for an enum
        /// its case's place first. False where a part cannot be written whole.
        ///
        /// Its bytes must tell apart every two values that differ; a test that lists the type's stored properties
        /// by `Mirror` keeps a property added later from being left out, and an exhaustive `switch` over an enum's
        /// cases keeps a case added later from compiling unwritten.
        public protocol Written {
            func write(into writer: Swift.Mirror.Writer) -> Bool
        }
    }
#endif
