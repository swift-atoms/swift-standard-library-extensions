#if !hasFeature(Embedded)
    extension Swift.Mirror.Writer {
        /// An array's storage: where its elements lie, how many, of what type, and whether a `Swift.Mirror.Written`
        /// type writes them itself, through `shared(_:_:)`, or the writer does.
        struct Run: Hashable {
            let address: UInt
            let count: Int
            let type: ObjectIdentifier
            let own: Bool
        }
    }
#endif
