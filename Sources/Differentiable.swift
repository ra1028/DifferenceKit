/// Represents the value that identified and can be compared to whether has updated.
public protocol Differentiable {
    /// A type representing the identifier.
    associatedtype DifferenceIdentifier: Hashable

    /// An identifier value for difference calculation.
    var differenceIdentifier: DifferenceIdentifier { get }

    /// Indicate whether the content of `self` is equals to the content of
    /// the given source value.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether the content of `self` is equals
    ///            to the content of the given source value.
    func isContentEqual(to source: Self) -> Bool
}

public extension Differentiable where Self: Equatable {
    /// Indicate whether the content of `self` is equals to the content of the given source value.
    /// Updates are compared using `==` operator of `Equatable'.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether the content of `self` is equals
    ///            to the content of the given source value.
    func isContentEqual(to source: Self) -> Bool {
        return self == source
    }
}

public extension Differentiable where Self: Hashable {
    /// The `self` value as an identifier for difference calculation.
    var differenceIdentifier: Self {
        return self
    }
}
