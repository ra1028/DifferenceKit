/// Represents a value that can compare whether the content are equal.
public protocol ContentEquatable {
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

public extension ContentEquatable where Self: Equatable {
    /// Indicate whether the content of `self` is equals to the content of the given source value.
    /// Updates are compared using `==` operator of `Equatable'.
    ///
    /// - Parameters:
    ///   - source: A source value to be compared.
    ///
    /// - Returns: A Boolean value indicating whether the content of `self` is equals
    ///            to the content of the given source value.
    @inlinable
    func isContentEqual(to source: Self) -> Bool {
        return self == source
    }
}
