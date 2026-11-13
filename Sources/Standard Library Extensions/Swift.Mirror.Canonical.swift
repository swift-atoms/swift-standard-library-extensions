#if !hasFeature(Embedded)
    extension Swift.Mirror {
        /// A type whose stored state holds something derived that need not be the same in every process, such as
        /// a cached `Hasher` value: `bytes(of:)` writes its `canonical` value in its place, after its own type.
        ///
        /// The canonical value must hold everything that decides the value; a test that lists the type's stored
        /// properties by `Mirror` keeps a property added later from being left out.
        public protocol Canonical {
            var canonical: Any { get }
        }
    }
#endif
