import XCTest
import DifferenceKit

final class ArraySectionTestCase: XCTestCase {
    func testReinitialize() {
        let s1 = ArraySection(model: D.a, elements: [0])
        let s2 = ArraySection(model: s1.model, elements: s1.elements)

        XCTAssertEqual(s1.model.differenceIdentifier, s2.model.differenceIdentifier)
        XCTAssertEqual(s1.model.differenceIdentifier.hashValue, s2.model.differenceIdentifier.hashValue)
        XCTAssertEqual(s1.elements, s2.elements)
    }
}
