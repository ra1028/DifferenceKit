import XCTest
import DifferenceKit

final class AnyDifferentiableTestCase: XCTestCase {
    func testHashable() {
        let base1 = M(0, false)

        let d1 = AnyDifferentiable(base1)
        let d2 = AnyDifferentiable(base1)

        XCTAssertEqual(d1.identifier.hashValue, d2.identifier.hashValue)
        XCTAssertEqual(d1.identifier, d2.identifier)
        XCTAssertTrue(d1.isContentEqual(to: d2))

        let base2 = M(1, false)

        let d3 = AnyDifferentiable(base1)
        let d4 = AnyDifferentiable(base2)

        XCTAssertNotEqual(d3.identifier.hashValue, d4.identifier.hashValue)
        XCTAssertNotEqual(d3.identifier, d4.identifier)
        XCTAssertFalse(d3.isContentEqual(to: d4))

        let base3 = M(1, true)

        let d5 = AnyDifferentiable(base2)
        let d6 = AnyDifferentiable(base3)

        XCTAssertEqual(d5.identifier.hashValue, d6.identifier.hashValue)
        XCTAssertEqual(d5.identifier, d6.identifier)
        XCTAssertFalse(d5.isContentEqual(to: d6))
    }
}
