import XCTest
import DifferenceKit

final class ChangesetTestCase: XCTestCase {
    func testchangeCount() {
        let c1 = Changeset(data: [()], sectionDeleted: [0, 1])
        XCTAssertEqual(c1.changeCount, 2)

        let c2 = Changeset(data: [()], sectionInserted: [0, 1, 2])
        XCTAssertEqual(c2.changeCount, 3)

        let c3 = Changeset(data: [()], sectionUpdated: [0, 1, 2, 3])
        XCTAssertEqual(c3.changeCount, 4)

        let c4 = Changeset(data: [()], sectionMoved: [(source: 0, target: 1)])
        XCTAssertEqual(c4.changeCount, 1)

        let c5 = Changeset(
            data: [()],
            elementDeleted: [ElementPath(element: 0, section: 0), ElementPath(element: 1, section: 1)]
        )
        XCTAssertEqual(c5.changeCount, 2)

        let c6 = Changeset(
            data: [()],
            elementInserted: [ElementPath(element: 0, section: 0), ElementPath(element: 1, section: 1)]
        )
        XCTAssertEqual(c6.changeCount, 2)

        let c7 = Changeset(
            data: [()],
            elementUpdated: [ElementPath(element: 0, section: 0), ElementPath(element: 1, section: 1)]
        )
        XCTAssertEqual(c7.changeCount, 2)

        let c8 = Changeset(
            data: [()],
            elementMoved: [(source: ElementPath(element: 0, section: 0), target: ElementPath(element: 1, section: 1))]
        )
        XCTAssertEqual(c8.changeCount, 1)

        let c9 = Changeset(
            data: [()],
            sectionDeleted: [0],
            sectionInserted: [1],
            sectionUpdated: [2],
            sectionMoved: [(source: 3, target: 4)],
            elementDeleted: [ElementPath(element: 5, section: 6)],
            elementInserted: [ElementPath(element: 7, section: 8)],
            elementUpdated: [ElementPath(element: 9, section: 10)],
            elementMoved: [(source: ElementPath(element: 11, section: 12), target: ElementPath(element: 13, section: 14))]
        )
        XCTAssertEqual(c9.changeCount, 8)
    }

    func testHasChanges() {
        let c1 = Changeset(data: [()])
        XCTAssertFalse(c1.hasChanges)

        let c2 = Changeset(data: [()], sectionDeleted: [0])
        XCTAssertTrue(c2.hasChanges)
    }

    func testEquatable() {
        let data = [0]

        let c1 = Changeset(
            data: data,
            sectionDeleted: [0, 1, 2],
            sectionInserted: [3, 4, 5],
            sectionUpdated: [6, 7, 8],
            sectionMoved: [
                (source: 9, target: 10),
                (source: 11, target: 12)
            ],
            elementDeleted: [ElementPath(element: 13, section: 14), ElementPath(element: 15, section: 16)],
            elementInserted: [ElementPath(element: 17, section: 18), ElementPath(element: 19, section: 20)],
            elementUpdated: [ElementPath(element: 21, section: 22), ElementPath(element: 23, section: 24)],
            elementMoved: [
                (source: ElementPath(element: 25, section: 26), target: ElementPath(element: 27, section: 28)),
                (source: ElementPath(element: 29, section: 30), target: ElementPath(element: 31, section: 32))
            ]
        )

        let c2 = Changeset(
            data: data,
            sectionDeleted: [2, 0, 1],
            sectionInserted: [3, 5, 4],
            sectionUpdated: [7, 6, 8],
            sectionMoved: [
                (source: 11, target: 12),
                (source: 9, target: 10)
            ],
            elementDeleted: [ElementPath(element: 15, section: 16), ElementPath(element: 13, section: 14)],
            elementInserted: [ElementPath(element: 19, section: 20), ElementPath(element: 17, section: 18)],
            elementUpdated: [ElementPath(element: 23, section: 24), ElementPath(element: 21, section: 22)],
            elementMoved: [
                (source: ElementPath(element: 29, section: 30), target: ElementPath(element: 31, section: 32)),
                (source: ElementPath(element: 25, section: 26), target: ElementPath(element: 27, section: 28))
            ]
        )

        // Should be equal ignoring the order of each changes
        XCTAssertEqual(c1, c2)

        let c3 = Changeset(data: data, sectionMoved: [(source: 0, target: 1)])
        let c4 = Changeset(data: data, sectionMoved: [(source: 1, target: 0)])

        // Should not be equal if the section move's source and target are exchanged
        XCTAssertNotEqual(c3, c4)

        let c5 = Changeset(
            data: data,
            elementMoved: [
                (source: ElementPath(element: 0, section: 1), target: ElementPath(element: 2, section: 3))
            ]
        )

        let c6 = Changeset(
            data: data,
            elementMoved: [
                (source: ElementPath(element: 1, section: 0), target: ElementPath(element: 2, section: 3))
            ]
        )

        // Should not be equal if the element move's source and target are exchanged
        XCTAssertNotEqual(c5, c6)
    }
}
