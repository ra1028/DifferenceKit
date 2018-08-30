import DifferenceKit
import XCTest

final class SectionData: Differentiable {
    // MARK: - Properties
    let title: String
    
    // MARK: - Differentiable
    let differenceIdentifier: UUID
    
    // MARK: - Init
    init(
        differenceIdentifier: UUID,
        title: String)
    {
        self.differenceIdentifier = differenceIdentifier
        self.title = title
    }
    
    // MARK: - Differentiable
    func isContentEqual(to source: SectionData) -> Bool {
        XCTAssert(
            self.differenceIdentifier == source.differenceIdentifier,
            "We expect the algorythm to compare items only with same `differenceIdentifier`"
        )
        
        return self.title == source.title
    }
    
    // MARK: - Internal
//    func isContentEqual(to source: SectionData, calledInDifferenceKitAlgorithm) -> Bool {
}
