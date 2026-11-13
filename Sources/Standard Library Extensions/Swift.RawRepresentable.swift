#if !hasFeature(Embedded)
    extension Swift.RawRepresentable {
        /// The raw value, written by a mirror's writer as the value it is.
        func written(by writer: Swift.Mirror.Writer) -> Bool {
            writer.write(self.rawValue)
        }
    }
#endif
