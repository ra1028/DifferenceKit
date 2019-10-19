import XCTest
import DifferenceKit

final class AnyDifferentiableTestCase: XCTestCase {
    func testHashable() {
        let base1 = M(0, false)

        let d1 = AnyDifferentiable(base1)
        let d2 = AnyDifferentiable(base1)

        XCTAssertEqual(d1.id.hashValue, d2.id.hashValue)
        XCTAssertEqual(d1.id, d2.id)
        XCTAssertTrue(d1.isContentEqual(to: d2))

        let base2 = M(1, false)

        let d3 = AnyDifferentiable(base1)
        let d4 = AnyDifferentiable(base2)

        XCTAssertNotEqual(d3.id.hashValue, d4.id.hashValue)
        XCTAssertNotEqual(d3.id, d4.id)
        XCTAssertFalse(d3.isContentEqual(to: d4))

        let base3 = M(1, true)

        let d5 = AnyDifferentiable(base2)
        let d6 = AnyDifferentiable(base3)

        XCTAssertEqual(d5.id.hashValue, d6.id.hashValue)
        XCTAssertEqual(d5.id, d6.id)
        XCTAssertFalse(d5.isContentEqual(to: d6))
    }

    func testRedundantWrapping() {
        let differentiable = 0
        let anyDifferentiable1 = AnyDifferentiable(differentiable)
        let anyDifferentiable2 = AnyDifferentiable(anyDifferentiable1)

        XCTAssertEqual(anyDifferentiable1.base as? Int, differentiable)
        XCTAssertEqual(anyDifferentiable2.base as? Int, differentiable)
        XCTAssertEqual(anyDifferentiable1.base as? Int, anyDifferentiable2.base as? Int)
    }
}
