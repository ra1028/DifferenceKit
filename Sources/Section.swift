/// A generic differentiable section.
///
/// Arrays are can not be identify each one and comparing whether has updated from other one.
/// Section is a generic wrapper to hold a model and elements to allow it.
public struct Section<Model: Differentiable, Element: Differentiable>: DifferentiableSection {
    /// The model of section for differentiated with other section.
    public var model: Model
    /// The array of element in the section.
    public var elements: [Element]

    /// Creates a section from the model and the elements.
    ///
    /// - Parameters:
    ///   - model: A model of section.
    ///   - elements: The collection of element in the section.
    public init<C: Collection>(model: Model, elements: C) where C.Element == Element {
        self.model = model
        self.elements = Array(elements)
    }
}

extension Section: Equatable where Model: Equatable, Element: Equatable {
    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.model == rhs.model && lhs.elements == rhs.elements
    }
}

extension Section: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard !elements.isEmpty else {
            return "Section(model: \(model), elements: [])"
        }

        return """
        Section(
            model: \(model),
            elements: \(elements)
        )
        """
    }
}
