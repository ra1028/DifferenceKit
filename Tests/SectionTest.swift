import XCTest
import DifferenceKit

final class SectionTestCase: XCTestCase {
    func testReinitialize() {
        let s1 = Section(model: D.a, elements: [0])
        let s2 = Section(model: s1.model, elements: s1.elements)

        XCTAssertEqual(s1.model.identifier, s2.model.identifier)
        XCTAssertEqual(s1.model.identifier.hashValue, s2.model.identifier.hashValue)
        XCTAssertEqual(s1.elements, s2.elements)
    }
}
