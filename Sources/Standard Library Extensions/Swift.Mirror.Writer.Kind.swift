#if !hasFeature(Embedded)
    extension Swift.Mirror.Writer {
        /// What follows a part's type.
        enum Kind: UInt8 {
            case memory = 0
            case text = 1
            case run = 2
            case optional = 3
            case choice = 4
            case unordered = 5
            case object = 6
            case cycle = 7
            case fields = 8
            case again = 9
            case written = 10
        }
    }

    extension Swift.Mirror.Writer.Kind {
        /// The byte that stands for this kind.
        var byte: UInt8 { self.rawValue }
    }
#endif
