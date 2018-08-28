import DifferenceKit
import XCTest

final class CellData: Differentiable {
    // MARK: - Properties
    let title: String
    let subtitle: String
    
    // MARK: - Differentiable
    let differenceIdentifier: UUID
    
    // MARK: - Init
    init(
        differenceIdentifier: UUID,
        title: String,
        subtitle: String)
    {
        self.differenceIdentifier = differenceIdentifier
        self.title = title
        self.subtitle = subtitle
    }
    
    // MARK: - Differentiable
    func isContentEqual(to source: CellData) -> Bool {
        XCTAssert(
            self.differenceIdentifier == source.differenceIdentifier,
            "We expect the algorythm to compare items only with same `differenceIdentifier`"
        )
        
        return self.title == source.title
            && self.subtitle == source.subtitle
    }
}
