/// Represents the section of collection that has model and elements that identified and can be compared to whether has updated.
public protocol DifferentiableSection {
    /// A type representing the model for differentiated with other section.
    associatedtype Model: Differentiable
    /// A type representing the elements in section.
    associatedtype Collection: Swift.Collection where Collection.Element: Differentiable

    /// The model of section for differentiated with other section.
    var model: Model { get }
    /// The collection of element in the section.
    var elements: Collection { get }

    /// Creates a section from the model and the elements.
    ///
    /// - Parameters:
    ///   - model: A model of section.
    ///   - elements: The collection of element in the section.
    init<C: Swift.Collection>(model: Model, elements: C) where C.Element == Collection.Element
}
