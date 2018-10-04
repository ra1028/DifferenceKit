import XCTest
import DifferenceKit

final class ContentEquatableTestCase: XCTestCase {
    func testEquatableValue() {
        let value1 = D.a
        let value2 = D.a
        let value3 = D.b

        XCTAssertEqual(value1, value2)
        XCTAssertTrue(value1.isContentEqual(to: value2))

        XCTAssertNotEqual(value1, value3)
        XCTAssertFalse(value1.isContentEqual(to: value3))
    }

    func testOptionalValue() {
        let value1: D? = .a
        let value2: D? = .a
        let value3: D? = .b

        XCTAssertTrue(value1.isContentEqual(to: value2))
        XCTAssertFalse(value1.isContentEqual(to: value3))
        XCTAssertFalse(value1.isContentEqual(to: nil))
        XCTAssertFalse(D?.none.isContentEqual(to: value1))
        XCTAssertTrue(D?.none.isContentEqual(to: nil))
    }
}
