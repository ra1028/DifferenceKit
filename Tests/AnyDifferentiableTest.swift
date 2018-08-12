import XCTest
import DifferenceKit

final class AnyDifferentiableTestCase: XCTestCase {
    func testHashable() {
        let base1 = M(0, false)

        let d1 = AnyDifferentiable(base1)
        let d2 = AnyDifferentiable(base1)

        XCTAssertEqual(d1.differenceIdentifier.hashValue, d2.differenceIdentifier.hashValue)
        XCTAssertEqual(d1.differenceIdentifier, d2.differenceIdentifier)
        XCTAssertTrue(d1.isContentEqual(to: d2))

        let base2 = M(1, false)

        let d3 = AnyDifferentiable(base1)
        let d4 = AnyDifferentiable(base2)

        XCTAssertNotEqual(d3.differenceIdentifier.hashValue, d4.differenceIdentifier.hashValue)
        XCTAssertNotEqual(d3.differenceIdentifier, d4.differenceIdentifier)
        XCTAssertFalse(d3.isContentEqual(to: d4))

        let base3 = M(1, true)

        let d5 = AnyDifferentiable(base2)
        let d6 = AnyDifferentiable(base3)

        XCTAssertEqual(d5.differenceIdentifier.hashValue, d6.differenceIdentifier.hashValue)
        XCTAssertEqual(d5.differenceIdentifier, d6.differenceIdentifier)
        XCTAssertFalse(d5.isContentEqual(to: d6))
    }
}
