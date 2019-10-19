import XCTest
import DifferenceKit

final class ArraySectionTestCase: XCTestCase {
    func testReinitialize() {
        let s1 = ArraySection(model: D.a, elements: [0])
        let s2 = ArraySection(model: s1.model, elements: s1.elements)

        XCTAssertEqual(s1.model.id, s2.model.id)
        XCTAssertEqual(s1.model.id.hashValue, s2.model.id.hashValue)
        XCTAssertEqual(s1.elements, s2.elements)
    }
}
