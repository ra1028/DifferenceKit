/// A generic differentiable section.
///
/// Arrays are can not be identify each one and comparing whether has updated from other one.
/// Section is a generic wrapper to hold a model and elements to allow it.
public struct Section<Model: Differentiable, Element: Differentiable>: DifferentiableSection {
    /// The model of section for differentiated with other section.
    public var model: Model
    /// The array of element in the section.
    public var elements: [Element]

    /// An identifier value that of model for difference calculation.
    public var differenceIdentifier: Model.DifferenceIdentifier {
        return model.differenceIdentifier
    }

    /// Creates a section from the model and the elements.
    ///
    /// - Parameters:
    ///   - model: A differentiable model of section.
    ///   - elements: The collection of element in the section.
    public init<C: Collection>(model: Model, elements: C) where C.Element == Element {
        self.model = model
        self.elements = Array(elements)
    }

    /// Creates a new section reproding the given source section with replacing the elements.
    ///
    /// - Parameters:
    ///   - source: A source section to reproduce.
    ///   - elements: The collection of elements for the new section.
    public init<C: Collection>(source: Section, elements: C) where C.Element == Element {
        self.init(model: source.model, elements: elements)
    }

    /// Indicate whether the content of `self` is equals to the content of
    /// the given source section.
    ///
    /// - Note: It's compared by the model of `self` and the specified section.
    ///
    /// - Parameters:
    ///   - source: A source section to compare.
    ///
    /// - Returns: A Boolean value indicating whether the content of `self` is equals
    ///            to the content of the given source section.
    public func isContentEqual(to source: Section) -> Bool {
        return model.isContentEqual(to: source.model)
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
