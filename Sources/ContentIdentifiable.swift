/// Represents the value that identified for differentiate.
public protocol ContentIdentifiable {
    /// A type representing the identifier.
    associatedtype DifferenceIdentifier: Hashable

    /// An identifier value for difference calculation.
    var differenceIdentifier: DifferenceIdentifier { get }
}

public extension ContentIdentifiable where Self: Hashable {
    /// The `self` value as an identifier for difference calculation.
    @inlinable
    var differenceIdentifier: Self {
        return self
    }
}

public extension MutableCollection where Element: ContentIdentifiable {
    /// Accesses and set the element on Collection with spesific `DifferenceIdentifier` identifier.
    ///
    /// - Note: If the element doesn't exist, the operation will be cancelled.
    ///
    /// For example, you can replace an element of an array by using its
    /// subscript.
    ///
    ///     struct Counter {
    ///         let differenceIdentifier: String
    ///         let count: Int
    ///     }
    ///
    ///     var counters = [
    ///         Counter(differenceIdentifier: "first", count: 0),
    ///         Counter(differenceIdentifier: "second", count: 1)
    ///     ]
    ///     counters[id: "first"]?.count = 100
    ///     print(counters[id: "first"])
    ///     // Prints "Counter(differenceIdentifier: "first", count: 100)"
    ///
    /// - Parameter id: The identifier of the `ContentIdentifiable`
    ///
    /// - Complexity: O(1)
    @inlinable
    subscript(id identifier: Element.DifferenceIdentifier) -> Element? {
        set {
            guard
                let index = firstIndex(where: { $0.differenceIdentifier == identifier }),
                let newValue = newValue
            else {
                return
            }

            self[index] = newValue
        }
        get {
            first(where: { $0.differenceIdentifier == identifier })
        }
    }
}
