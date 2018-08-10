/// Represents the value that identified and can be compared to whether has updated.
public protocol Differentiable {
    /// A type representing the identifier.
    associatedtype Identifier: Hashable

    /// An identifier value for difference calculation.
    var identifier: Identifier { get }

    /// Indicate whether `self` has updated from given source value.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether `self` has updated from given source value.
    func isUpdated(from source: Self) -> Bool
}

public extension Differentiable where Self: Equatable {
    /// Indicate whether `self` has updated from given source value.
    /// Updates are compared using `!=` operator of `Equatable'.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether `self` has updated from given source value.
    func isUpdated(from source: Self) -> Bool {
        return self != source
    }
}

public extension Differentiable where Self: Hashable {
    /// The `self` value as an identifier for difference calculation.
    var identifier: Self {
        return self
    }
}
