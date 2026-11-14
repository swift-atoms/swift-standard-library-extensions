#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// The bytes of a value's structure as reflection shows it, the same in every process and every run: a key
        /// for the value that outlives the process, which `Hasher` is not.
        ///
        /// A value of a `Swift.Mirror.Canonical` type is written as the value it gives for itself. Each part is
        /// written with its type's name, so values of different types never meet. A number, a truth value, and a
        /// structure or tuple of them with no byte between its fields is written as its memory; a string as its UTF-8; an array of such parts as its
        /// elements' memory; a dictionary or set with its members in the order of their own bytes, never the
        /// order of the process's hashing; an enum with its case, a case without a payload as its one byte of memory, its raw value or its name; anything else as its stored properties, one by
        /// one, through `Mirror`. A reference already on the way down is written as how far up it is. An array of
        /// 256 bytes or more is written on its own, as a block that does not depend on what was written before it,
        /// and a block equal to one written before as which one that was: the bytes are a function of the value
        /// alone, the same whether its arrays share storage or are copies, and sharing only makes writing faster.
        ///
        /// Two values with equal bytes are equal in every stored property reflection shows. The reverse does not
        /// hold: equal values whose memory differs (`0.0` and `-0.0`, padding between fields, two spellings of
        /// one string) give different bytes. The value is nil when reflection cannot show it whole: a function,
        /// a type with its own `customMirror` from outside the standard library, or a value whose state has no
        /// stored property to show. A pointer is written as its address, which is not its pointee.
        public static func bytes<Subject>(of subject: Subject) -> [UInt8]? {
            let structure = Writer()
            guard structure.write(subject) else { return nil }
            return structure.bytes
        }

        /// `bytes(of:)` handed to `sink` a piece at a time as they are written, rather than gathered: the pieces
        /// are the bytes, in order. False, after some pieces perhaps, where `bytes(of:)` is nil.
        public static func bytes<Subject>(of subject: Subject, into sink: (borrowing RawSpan) -> Void) -> Bool {
            withoutActuallyEscaping(sink) { sink in
                let structure = Writer(sink: sink)
                guard structure.write(subject) else { return false }
                structure.flush()
                return true
            }
        }
    }
#endif
