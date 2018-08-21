import XCTest
import DifferenceKit

extension Int: Differentiable {}
extension String: Differentiable {}

enum D: Differentiable {
    case a, b, c, d, e

    // FIXME: This is not required after Swift 4.2. Use CaseIterable.
    static var allCases: [D] {
        return [.a, .b, .c, .d, .e]
    }
}

struct M: Differentiable, Equatable {
    let i: Int
    let b: Bool

    init(_ i: Int, _ b: Bool) {
        self.i = i
        self.b = b
    }

    var differenceIdentifier: Int {
        return i
    }
}

func XCTAssertExactDifferences<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    section: Int,
    expected: StagedChangeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: Differentiable {
    let stagedChangeset = StagedChangeset(source: source, target: target, section: section)

    XCTAssertEqual(stagedChangeset, expected, file: file, line: line)
    XCTAssertReproducible(source: source, target: target, stagedChangeset: stagedChangeset, file: file, line: line)
}

func XCTAssertExactDifferences<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    expected: StagedChangeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: DifferentiableSection {
    let stagedChangeset = StagedChangeset(source: source, target: target)

    XCTAssertEqual(stagedChangeset, expected, file: file, line: line)
    XCTAssertReproducible(source: source, target: target, stagedChangeset: stagedChangeset, file: file, line: line)
}

func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: Differentiable {
    let stagedChangeset = StagedChangeset(source: source, target: target)
    XCTAssertReproducible(source: source, target: target, stagedChangeset: stagedChangeset, file: file, line: line)
}

func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: DifferentiableSection {
    let stagedChangeset = StagedChangeset(source: source, target: target)
    XCTAssertReproducible(source: source, target: target, stagedChangeset: stagedChangeset, file: file, line: line)
}

func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    stagedChangeset: StagedChangeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: Differentiable {
    var source = source

    for changeset in stagedChangeset {
        source = XCTAssertReproducible(source: source, target: changeset.data, changeset: changeset, file: file, line: line)
    }

    XCTAssertEqual(source, target, file: file, line: line)
}

func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    stagedChangeset: StagedChangeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) where C.Element: DifferentiableSection {
    var source = source

    for changeset in stagedChangeset {
        source = XCTAssertReproducible(source: source, target: changeset.data, changeset: changeset, file: file, line: line)
    }

    XCTAssertEqual(source, target, file: file, line: line)
}

@discardableResult
func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    changeset: Changeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) -> C where C.Element: Differentiable {
    XCTAssertTrue(changeset.sectionDeleted.isEmpty, file: file, line: line)
    XCTAssertTrue(changeset.sectionInserted.isEmpty, file: file, line: line)
    XCTAssertTrue(changeset.sectionUpdated.isEmpty, file: file, line: line)
    XCTAssertTrue(changeset.sectionMoved.isEmpty, file: file, line: line)

    let reproduced = C(reproduce(
        source: ContiguousArray(source),
        target: ContiguousArray(target),
        deleted: changeset.elementDeleted.map { $0.element },
        inserted: changeset.elementInserted.map { $0.element },
        updated: changeset.elementUpdated.map { $0.element },
        moved: changeset.elementMoved.map { (source: $0.source.element, target: $0.target.element) }
    ))

    XCTAssertEqual(reproduced, target, file: file, line: line)

    return reproduced
}

@discardableResult
func XCTAssertReproducible<C: RangeReplaceableCollection & Equatable>(
    source: C,
    target: C,
    changeset: Changeset<C>,
    file: StaticString = #file,
    line: UInt = #line
    ) -> C where C.Element: DifferentiableSection {
    typealias Section = C.Element

    let sourceSections = ContiguousArray(source.map { ContiguousArray($0.elements) })
    let targetSections = ContiguousArray(target.map { ContiguousArray($0.elements) })

    // 1. Apply differences of section.
    var subject = reproduce(
        source: ContiguousArray(source),
        target: ContiguousArray(target),
        deleted: changeset.sectionDeleted,
        inserted: changeset.sectionInserted,
        updated: changeset.sectionUpdated,
        moved: changeset.sectionMoved
    )

    var elementDeletionMap = [IndexSet](repeating: [], count: sourceSections.count)
    var elementInsertionMap = [IndexSet](repeating: [], count: targetSections.count)
    var elementMoveMap = [ElementPath: ElementPath](minimumCapacity: changeset.elementMoved.count * 2)
    var elementReferenceSourcePathMap = [ElementPath: ElementPath](minimumCapacity: changeset.elementMoved.count * 2)

    // 2. Decompose the deletions for each section.
    for elementPath in changeset.elementDeleted {
        elementDeletionMap[elementPath.section].insert(elementPath.element)
    }

    // 3. Decompose the insertions for each section.
    for elementPath in changeset.elementInserted {
        elementInsertionMap[elementPath.section].insert(elementPath.element)
    }

    // 4. Decompose the moves into insertion and deletion for each section.
    // 5. Mapping paths to retrieve elements to be inserted by move.
    for (sourceElementPath, targetElementPath) in changeset.elementMoved {
        elementDeletionMap[sourceElementPath.section].insert(sourceElementPath.element)
        elementInsertionMap[targetElementPath.section].insert(targetElementPath.element)
        elementMoveMap[sourceElementPath] = targetElementPath
        elementReferenceSourcePathMap[targetElementPath] = sourceElementPath
    }

    // 6. Decompose the updations into insertion and deletion for each section.
    //    Needs to offset by other movements.
    //    Remove the reference to the source to retrieves the updated element from the target.
    for sourceElementPath in changeset.elementUpdated {
        let targetElementPath: ElementPath
        if let movedTargetElementPath = elementMoveMap[sourceElementPath] {
            targetElementPath = movedTargetElementPath
        } else {
            let deleteOffset = elementDeletionMap[sourceElementPath.section].count(in: 0..<sourceElementPath.element)
            let insertOffset = elementInsertionMap[sourceElementPath.section].count(in: 0...sourceElementPath.element)
            targetElementPath = ElementPath(element: sourceElementPath.element - deleteOffset + insertOffset, section: sourceElementPath.section)
        }
        elementDeletionMap[sourceElementPath.section].insert(sourceElementPath.element)
        elementInsertionMap[targetElementPath.section].insert(targetElementPath.element)
        elementReferenceSourcePathMap[targetElementPath] = nil
    }

    let sectionDeletions = IndexSet(changeset.sectionDeleted).union(IndexSet(changeset.sectionMoved.map { $0.source }))
    let sectionInsertions = IndexSet(changeset.sectionInserted).union(IndexSet(changeset.sectionMoved.map { $0.target }))
    let sectionUpdations = IndexSet(changeset.sectionUpdated)

    // If the section is updated or deleted, no need to apply the element differences.
    let sectionIndices = IndexSet(sourceSections.indices)
        .symmetricDifference(sectionDeletions)
        .symmetricDifference(sectionUpdations)

    for sourceSectionIndex in sectionIndices {
        let deleteOffset = sectionDeletions.count(in: 0..<sourceSectionIndex)
        let insertOffset = sectionInsertions.count(in: 0...sourceSectionIndex)
        let targetSectionIndex = sourceSectionIndex - deleteOffset + insertOffset

        let section = subject[targetSectionIndex]
        var elements = ContiguousArray(section.elements)

        // 7. Apply element deletions including moves and updations.
        for range in elementDeletionMap[sourceSectionIndex].rangeView.reversed() {
            elements.removeSubrange(range)
        }

        // 8. Apply element insertions including moves and updations.
        for targetElementIndex in elementInsertionMap[targetSectionIndex] {
            let targetElementPath = ElementPath(element: targetElementIndex, section: targetSectionIndex)
            let sourceElementPath = elementReferenceSourcePathMap[targetElementPath]

            let element = sourceElementPath.map { sourceSections[$0.section][$0.element] } ?? targetSections[targetSectionIndex][targetElementPath.element]
            elements.insert(element, at: targetElementIndex)
        }

        subject[targetSectionIndex] = Section(source: section, elements: elements)
    }

    let reproduced = C(subject)
    XCTAssertEqual(reproduced, target, file: file, line: line)

    return reproduced
}

@discardableResult
func reproduce<E>(
    source: ContiguousArray<E>,
    target: ContiguousArray<E>,
    deleted: [Int],
    inserted: [Int],
    updated: [Int],
    moved: [(source: Int, target: Int)]
    ) -> ContiguousArray<E> {
    var subject = source

    // 1. Decompose the moves into insertion and deletion.
    var deletions = IndexSet(deleted).union(IndexSet(moved.map { $0.source }))
    var insertions = IndexSet(inserted).union(IndexSet(moved.map { $0.target }))
    let updations = IndexSet(updated)

    var targetReferenceIndices = ContiguousArray<Int?>(repeating: nil, count: target.count)

    // 2. Mapping indices to retrieve elements to be inserted by move.
    for (sourceIndex, targetIndex) in moved {
        targetReferenceIndices[targetIndex] = sourceIndex
    }

    // 3. Decompose the updations into insertion and deletion.
    //    Needs to offset by other movements.
    //    Remove the reference to the source to retrieves the updated element from the target.
    for range in updations.rangeView {
        let deleteOffset = deletions.count(in: 0..<range.lowerBound)
        let insertOffset = insertions.count(in: 0...range.lowerBound)
        let lowerBound = range.lowerBound - deleteOffset + insertOffset
        let insertionRange = lowerBound..<lowerBound + range.count
        deletions.insert(integersIn: range)
        insertions.insert(integersIn: insertionRange)
        targetReferenceIndices.replaceSubrange(insertionRange, with: Array(repeating: nil, count: insertionRange.count))
    }

    // 4. Apply deletions including moves and updations.
    for range in deletions.rangeView.reversed() {
        subject.removeSubrange(range)
    }

    // 5. Apply insertions including moves and updates.
    for targetIndex in insertions {
        let sourceIndex = targetReferenceIndices[targetIndex]
        let element = sourceIndex.map { source[$0] } ?? target[targetIndex]
        subject.insert(element, at: targetIndex)
    }

    return subject
}
