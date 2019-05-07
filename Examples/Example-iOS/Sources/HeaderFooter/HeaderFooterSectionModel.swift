import DifferenceKit

struct HeaderFooterSectionModel: Differentiable, Equatable {
    var id: Int
    var hasFooter: Bool

    var differenceIdentifier: Int {
        return id
    }

    var headerTitle: String {
        return "Section \(id)"
    }
}
