import Foundation
import DifferenceKit

struct RandomModel: Differentiable {
    var id: UUID
    var isUpdated: Bool

    var differenceIdentifier: UUID {
        return id
    }

    init(_ id: UUID = UUID(), _ isUpdated: Bool = false) {
        self.id = id
        self.isUpdated = isUpdated
    }

    func isContentEqual(to source: RandomModel) -> Bool {
        return isUpdated == source.isUpdated
    }
}
