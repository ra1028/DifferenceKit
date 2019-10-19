/// A class of types whose instances hold the value of an entity with stable identity.
public protocol ContentIdentifiable {
    ///  A type representing the stable identity of the entity associated with `self`.
    associatedtype ID: Hashable

    /// The stable identity of the entity associated with `self`.
    var id: ID { get }
}

public extension ContentIdentifiable where Self: Hashable {
    /// The `self` value as an identifier for difference calculation.
    @inlinable
    var id: Self {
        return self
    }
}
