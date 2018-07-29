/// A type-erased differentiable value.
///
/// The `AnyDifferentiable` type hides the specific underlying types.
/// `DifferenceIdentifier` type is erased by `AnyHashable`.
/// The comparisons of whether has updated is forwards to an underlying differentiable value.
///
/// You can store mixed-type elements in collection that require `Differentiable` conformance by
/// wrapping mixed-type elements in `AnyDifferentiable`:
///
///     extension String: Differentiable {}
///     extension Int: Differentiable {}
///
///     let source: [AnyDifferentiable] = [
///         AnyDifferentiable("ABC"),
///         AnyDifferentiable(100)
///     ]
///     let target: [AnyDifferentiable] = [
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
    /// A type-erased identifier value for differentiation.
    public let differenceIdentifier: AnyHashable

    private let isUpdatedFrom: (AnyDifferentiable) -> Bool

    /// Creates a type-erased differentiable value that wraps the given instance.
    ///
    /// - Parameters:
    ///   - base: A differentiable value to wrap.
    public init<D: Differentiable>(_ base: D) {
        self.base = base
        self.differenceIdentifier = AnyHashable(base.differenceIdentifier)

        self.isUpdatedFrom = { source in
            guard let sourceBase = source.base as? D else { return false }
            return base.isUpdated(from: sourceBase)
        }
    }

    /// Indicate whether `base` has updated from given source value.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether `base` has updated from given source value.
    public func isUpdated(from source: AnyDifferentiable) -> Bool {
        return isUpdatedFrom(source)
    }
}

extension AnyDifferentiable: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "AnyDifferentiable(\(String(reflecting: base))"
    }
}
