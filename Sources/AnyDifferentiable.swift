/// A type-erased differentiable value.
///
/// The `AnyDifferentiable` type hides the specific underlying types.
/// Associated type `DifferenceIdentifier` is erased by `AnyHashable`.
/// The comparisons of whether has updated is forwards to an underlying differentiable value.
///
/// You can store mixed-type elements in collection that require `Differentiable` conformance by
/// wrapping mixed-type elements in `AnyDifferentiable`:
///
///     extension String: Differentiable {}
///     extension Int: Differentiable {}
///
///     let source = [
///         AnyDifferentiable("ABC"),
///         AnyDifferentiable(100)
///     ]
///     let target = [
///         AnyDifferentiable("ABC"),
///         AnyDifferentiable(100),
///         AnyDifferentiable(200)
///     ]
///
///     let changeset = StagedChangeset(source: source, target: target)
///     print(changeset.isEmpty)  // prints "false"
public struct AnyDifferentiable: Differentiable {
    /// The value wrapped by this instance.
    public let base: Any
    /// A type-erased identifier value for difference calculation.
    public let differenceIdentifier: AnyHashable

    private let isContentEqualTo: (AnyDifferentiable) -> Bool

    /// Creates a type-erased differentiable value that wraps the given instance.
    ///
    /// - Parameters:
    ///   - base: A differentiable value to wrap.
    public init<D: Differentiable>(_ base: D) {
        self.base = base
        self.differenceIdentifier = AnyHashable(base.differenceIdentifier)

        self.isContentEqualTo = { source in
            guard let sourceBase = source.base as? D else { return false }
            return base.isContentEqual(to: sourceBase)
        }
    }

    /// Indicate whether the content of `base` is equals to the content of the given source value.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether the content of `base` is equals
    ///            to the content of `base` of the given source value.
    public func isContentEqual(to source: AnyDifferentiable) -> Bool {
        return isContentEqualTo(source)
    }
}

extension AnyDifferentiable: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "AnyDifferentiable(\(String(reflecting: base))"
    }
}
