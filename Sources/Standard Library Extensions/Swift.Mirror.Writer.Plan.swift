#if !hasFeature(Embedded)
    extension Swift.Mirror.Writer {
        /// How the values of one type are written.
        enum Plan {
            /// As their memory: the type holds no references.
            case memory
            /// As their UTF-8.
            case text
            /// As an array.
            case run
            /// Not at all: the type writes its own mirror.
            case refused
            /// Through `Mirror`.
            case reflected
            /// As the value it gives for itself.
            case canonical
            /// As it writes itself.
            case written
        }
    }
#endif
