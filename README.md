# swift-standard-library-extensions

Use this package when code needs a convenience the Swift standard library leaves out, and should get it without importing Foundation: result-builder initializers for the standard containers (`Swift.Array.Builder`, `Swift.Dictionary.Builder`, `Swift.Set.Builder`, `Swift.String.Builder` and their siblings), quantifiers over `Bool` (`Swift.Bool.Builder`), first-success and collect-all composition of results (`Swift.Result.Builder`), bounds-checked element access that returns `nil` instead of trapping, typed-throws versions of the standard library's scoped unsafe-pointer functions, and `Swift.Actor.run` for several steps of actor-isolated work in one hop. Every API is an extension of a standard-library type or a top-level function. Start from the standard-library type you already hold.

## Laws

- Builders evaluate every component and never short-circuit, `Swift.Bool.Builder.All` and `Swift.Optional.Builder` included.
- `Swift.Dictionary.Builder`: when a key repeats, the later value wins, within one expression and across components. `Swift.Set.Builder` takes the union of its components.
- `Swift.String.Builder` and `Swift.Substring.Builder` join components with `"\n"`. An empty string or a skipped `if` after the first non-empty component adds an empty line. Empty components before it are dropped.
- `Swift.Optional.Builder` gives the first non-`nil` component. `Swift.Result.Builder.First` gives the first success, or the last failure if every component fails. A block whose only components are skipped `if`s gives `nil`. `Swift.Result.Builder.All` keeps successes in source order, and the first failure wins.
- An empty block or a skipped `if` contributes the identity: `true` for `all` and `none`, `false` for `any`, `0` for `count`. `one` is `true` exactly when one component is `true`.
- `Swift.ClosedRange.Builder` turns a bare bound `x` into `x...x`.
- `element(at:)` and `elements(in:)` return `nil` for any index or range outside the collection and never trap. `elements(in:)` checks against the receiver's own indices, so a slice rejects indices of its base that lie outside the slice.
- `chunks(of:)` returns slices that share the receiver's indices and storage. Every chunk is full except possibly the last. A size of zero or less gives no chunks. `chunked(into:)` copies the chunks into arrays.
- `move(offsets:to:)` sorts and de-duplicates the offsets first. The moved elements keep their relative order and land in front of the element that was at `destination`. A destination inside the moved block leaves the collection unchanged. A destination outside `startIndex...endIndex` traps.
- `range(of:)` compares UTF-8 bytes. It is case-sensitive, does not apply canonical equivalence (a precomposed `é` does not match `e` followed by U+0301), and returns the first match. An empty needle matches the empty range at `startIndex`.
- `Swift.Range` `overlap(_:)` and `clamped(to:)` return `nil` when the intersection is empty, so ranges that only touch give `nil`. On `Swift.ClosedRange`, ranges that touch give a single point. `split(at:)` returns `nil` unless the point lies strictly between the bounds.
- `power(_:)` returns `0` for a negative exponent, not the reciprocal. `rounded(to:)` returns the value unchanged for a negative number of places and otherwise rounds half away from zero.
- `max(count:)` returns the largest elements in descending order, and `min(count:)` the smallest in ascending order. Both return at most `count` elements. `mean()` returns `nil` for an empty sequence. On integers it divides with truncation.
- `uniqued()` keeps the first occurrence of each element, in order.
- If two values are equal, `inverted()` keeps one of their keys, chosen by dictionary iteration order. The same goes for `mapKeys(_:)` and `compactMapKeys(_:)` when two keys map to the same new key.
- `replace(_:with:)` inserts the replacement only if the member was present. `toggle(_:)` removes a present member and inserts an absent one.
- Setting `isPresent` to `false` clears the optional. Setting it to `true` does nothing.
- `lowercasingLeadingUppercase` lowercases a leading run of capitals. When more text follows the run, its last capital stays, because that capital starts the next word (`URLRequest` becomes `urlRequest`).
- `Swift.Set<String>.Swift.escape(_:)` adds backticks only to words in `Swift.Set<String>.Swift.keywords`.
- `Swift.Actor.run` with a synchronous body runs it as one isolated step, so no other work on the actor runs in between. The async overload can interleave at every `await`.
- `eraseToThrowingStream()` runs the iteration in a new unstructured `Task`. When the stream terminates, that task is cancelled. If the loop sees cancellation between elements, it finishes the stream without throwing. Any error the base sequence throws is passed on to the stream.
