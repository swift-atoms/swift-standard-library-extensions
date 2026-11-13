#if !hasFeature(Embedded)
    extension Swift.Mirror.Writer {
        /// What the writer knows of a type: how its values are written, and its order among the types named, once
        /// it has been named.
        struct Known {
            let plan: Plan
            var order: Int?
        }
    }
#endif
