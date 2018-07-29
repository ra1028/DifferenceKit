import XCTest
import DifferenceKit

final class StagedChangesetTestCase: XCTestCase {
    func testEquatable() {
        let data = [0]

        let c1 = StagedChangeset<[Int]>()
        let c2 = StagedChangeset<[Int]>()

        // Should be equal if both are empty
        XCTAssertEqual(c1, c2)

        let c3 = StagedChangeset([
            Changeset(data: data, sectionDeleted: [2, 0, 1])
            ])

        let c4 = StagedChangeset([
            Changeset(data: data, sectionDeleted: [0, 1, 2])
            ])

        // Should be equal ignoring the order of each inner changes
        XCTAssertEqual(c3, c4)

        let c5 = StagedChangeset([
            Changeset(data: data, sectionDeleted: [0, 1, 2]),
            Changeset(data: data, sectionInserted: [3, 4, 5])
            ])

        let c6 = StagedChangeset([
            Changeset(data: data, sectionInserted: [3, 4, 5]),
            Changeset(data: data, sectionDeleted: [0, 1, 2])
            ])

        // Should not equal if the order of Changeset is different
        XCTAssertNotEqual(c5, c6)
    }
}
