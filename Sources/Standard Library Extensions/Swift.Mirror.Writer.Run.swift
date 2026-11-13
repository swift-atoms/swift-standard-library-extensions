#if !hasFeature(Embedded)
    extension Swift.Mirror.Writer {
        /// An array's storage: where its elements lie, how many, and of what type.
        struct Run: Hashable {
            let address: UInt
            let count: Int
            let type: ObjectIdentifier
        }
    }
#endif
