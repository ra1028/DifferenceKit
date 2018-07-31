import XCTest
import DifferenceKit

final class ElementPathTestCase: XCTestCase {
    func testHashable() {
        let e1 = ElementPath(element: 0, section: 0)
        let e2 = ElementPath(element: 0, section: 0)

        XCTAssertEqual(e1, e2)
        XCTAssertEqual(e1.hashValue, e2.hashValue)

        let e3 = ElementPath(element: 0, section: 0)
        let e4 = ElementPath(element: 0, section: 1)

        XCTAssertNotEqual(e3, e4)
        XCTAssertNotEqual(e3.hashValue, e4.hashValue)

        let e5 = ElementPath(element: 0, section: 0)
        let e6 = ElementPath(element: 1, section: 1)

        XCTAssertNotEqual(e5, e6)
        XCTAssertNotEqual(e5.hashValue, e6.hashValue)
    }
}
