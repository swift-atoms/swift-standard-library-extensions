#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// The bytes of a value's structure as reflection shows it, the same in every process and every run: a key
        /// for the value that outlives the process, which `Hasher` is not.
        ///
        /// Each part is written with its type's name, so values of different types never meet. A part whose type
        /// holds no references is written as its memory; a string as its UTF-8; an array of such parts as its
        /// elements' memory; a dictionary or set with its members in the order of their own bytes, never the
        /// order of the process's hashing; an enum with its case; anything else as its stored properties, one by
        /// one, through `Mirror`. A reference already on the way down is written as how far up it is.
        ///
        /// Two values with equal bytes are equal in every stored property reflection shows. The reverse does not
        /// hold: equal values whose memory differs (`0.0` and `-0.0`, padding between fields, two spellings of
        /// one string) give different bytes. The value is nil when reflection cannot show it whole: a function,
        /// a type with its own `customMirror` from outside the standard library, or a value whose state has no
        /// stored property to show. A pointer is written as its address, which is not its pointee.
        public static func bytes<Subject>(of subject: Subject) -> [UInt8]? {
            let structure = Structure()
            guard structure.write(subject) else { return nil }
            return structure.bytes
        }
    }
#endif
