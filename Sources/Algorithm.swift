public extension StagedChangeset where Collection: RangeReplaceableCollection, Collection.Element: Differentiable {
    /// Creates a new `StagedChangeset` from the two collections.
    ///
    /// Calculate the differences between the collections using
    /// the algorithm optimized based on the Paul Heckel's diff algorithm.
    ///
    /// - Note: This algorithm can compute the differences at high performance with O(n) complexity.
    ///         However, not always calculates the shortest differences.
    ///
    /// - Note: If the elements with the same identifier duplicated, the algorithm calculates
    ///         the moves at best effort, and rest of the duplicates as insertion or deletion.
    ///
    /// - Note: The data and changes each changeset contains are represents the middle of whole the changes.
    ///         Each changes are from the previous stage.
    ///
    /// - Parameters:
    ///   - source: A source collection to calculate differences.
    ///   - target: A target collection to calculate differences.
    ///
    /// - Complexity: O(n)
    public init(source: Collection, target: Collection) {
        self.init(source: source, target: target, section: 0)
    }

    /// Creates a new `StagedChangeset` from the two collections.
    ///
    /// Calculate the differences between the collections using
    /// the algorithm optimized based on the Paul Heckel's diff algorithm.
    ///
    /// - Note: This algorithm can compute the differences at high performance with O(n) complexity.
    ///         However, not always calculates the shortest differences.
    ///
    /// - Note: If the elements with the same identifier duplicated, the algorithm calculates
    ///         the moves at best effort, and rest of the duplicates as insertion or deletion.
    ///
    /// - Note: The data and changes each changeset contains are represents the middle of whole the changes.
    ///         Each changes are from the previous stage.
    ///
    /// - Parameters:
    ///   - source: A source collection to calculate differences.
    ///   - target: A target collection to calculate differences.
    ///   - section: An Int value to use as section index (or offset) of element.
    ///
    /// - Complexity: O(n)
    public init(source: Collection, target: Collection, section: Int) {
        let sourceElements = ContiguousArray(source)
        let targetElements = ContiguousArray(target)

        // Returns the empty changesets if both are empty.
        if sourceElements.isEmpty && targetElements.isEmpty {
            self.init()
            return
        }

        // Returns the changesets that all deletions if source is not empty and target is empty
        if !sourceElements.isEmpty && targetElements.isEmpty {
            self.init([Changeset(data: target, elementDeleted: sourceElements.indices.map { ElementPath(element: $0, section: section) })])
            return
        }

        // Returns the changesets that all insertions if source is empty and target is not empty
        if sourceElements.isEmpty && !targetElements.isEmpty {
            self.init([Changeset(data: target, elementInserted: targetElements.indices.map { ElementPath(element: $0, section: section) })])
            return
        }

        var firstStageElements = ContiguousArray<Collection.Element>()

        let result = differentiate(
            source: sourceElements,
            target: targetElements,
            trackTargetIndexAsUpdated: false,
            mapIndex: { ElementPath(element: $0, section: section) },
            remainedInTarget: { firstStageElements.append($0) }
        )

        var changesets = ContiguousArray<Changeset<Collection>>()

        // The 1st stage changeset.
        // - Includes:
        //   - element deletes
        //   - element updates
        if !result.deleted.isEmpty || !result.updated.isEmpty {
            changesets.append(
                Changeset(
                    data: Collection(firstStageElements),
                    elementDeleted: result.deleted,
                    elementUpdated: result.updated
                )
            )
        }

        // The 2st stage changeset.
        // - Includes:
        //   - element inserts
        //   - element moves
        if !result.inserted.isEmpty || !result.moved.isEmpty {
            changesets.append(
                Changeset(
                    data: target,
                    elementInserted: result.inserted,
                    elementMoved: result.moved
                )
            )
        }

        // Set the target to `data` of the last stage.
        if !changesets.isEmpty {
            let index = changesets.index(before: changesets.endIndex)
            changesets[index].data = target
        }

        self.init(changesets)
    }
}

public extension StagedChangeset where Collection: RangeReplaceableCollection, Collection.Element: DifferentiableSection {
    /// Creates a new `StagedChangeset` from the two sectioned collections.
    ///
    /// Calculate the differences between the collections using
    /// the algorithm optimized based on the Paul Heckel's diff algorithm.
    ///
    /// - Note: This algorithm can compute the differences at high performance with O(n) complexity.
    ///         However, not always calculates the shortest differences.
    ///
    /// - Note: If the elements with the same identifier duplicated, the algorithm calculates
    ///         the moves at best effort, and rest of the duplicates as insertion or deletion.
    ///
    /// - Note: The data and changes each changeset contains are represents the middle of whole the changes.
    ///         Each changes are from the previous stage.
    ///
    /// - Parameters:
    ///   - source: A source sectioned collection to calculate differences.
    ///   - target: A target sectioned collection to calculate differences.
    ///
    /// - Complexity: O(n)
    public init(source: Collection, target: Collection) {
        typealias Section = Collection.Element
        typealias SectionIdentifier = Collection.Element.DifferenceIdentifier
        typealias Element = Collection.Element.Collection.Element
        typealias ElementIdentifier = Collection.Element.Collection.Element.DifferenceIdentifier

        let sourceSections = ContiguousArray(source)
        let targetSections = ContiguousArray(target)

        let contiguousSourceSections = ContiguousArray(sourceSections.map { ContiguousArray($0.elements) })
        let contiguousTargetSections = ContiguousArray(targetSections.map { ContiguousArray($0.elements) })

        var firstStageSections = ContiguousArray<Section>()
        var secondStageSections = ContiguousArray<Section>()
        var thirdStageSections = ContiguousArray<Section>()

        var sourceElementTraces = contiguousSourceSections.map { section in
            ContiguousArray(repeating: Trace<ElementPath>(), count: section.count)
        }
        var targetElementReferences = contiguousTargetSections.map { section in
            ContiguousArray<ElementPath?>(repeating: nil, count: section.count)
        }

        let flattenSourceCount = contiguousSourceSections.reduce(into: 0) { $0 += $1.count }
        var flattenSourceIdentifiers = ContiguousArray<ElementIdentifier>()
        var flattenSourceElementPaths = ContiguousArray<ElementPath>()

        secondStageSections.reserveCapacity(contiguousTargetSections.count)
        thirdStageSections.reserveCapacity(contiguousTargetSections.count)

        flattenSourceIdentifiers.reserveCapacity(flattenSourceCount)
        flattenSourceElementPaths.reserveCapacity(flattenSourceCount)

        // Calculate the section differences.

        let sectionResult = differentiate(
            source: sourceSections,
            target: targetSections,
            trackTargetIndexAsUpdated: true,
            mapIndex: { $0 }
        )

        // Calculate the element differences.

        var elementDeleted = [ElementPath]()
        var elementInserted = [ElementPath]()
        var elementUpdated = [ElementPath]()
        var elementMoved = [(source: ElementPath, target: ElementPath)]()

        for sourceSectionIndex in contiguousSourceSections.indices {
            for sourceElementIndex in contiguousSourceSections[sourceSectionIndex].indices {
                let sourceElementPath = ElementPath(element: sourceElementIndex, section: sourceSectionIndex)
                let sourceElement = contiguousSourceSections[sourceElementPath]
                flattenSourceIdentifiers.append(sourceElement.differenceIdentifier)
                flattenSourceElementPaths.append(sourceElementPath)
            }
        }

        flattenSourceIdentifiers.withUnsafeBufferPointer { bufferPointer in
            // The pointer and the table key are for optimization.
            var sourceOccurrencesTable = [TableKey<ElementIdentifier>: Occurrence](minimumCapacity: flattenSourceCount * 2)

            // Record the index where the element was found in flatten source collection into occurrences table.
            for flattenSourceIndex in flattenSourceIdentifiers.indices {
                let pointer = bufferPointer.baseAddress!.advanced(by: flattenSourceIndex)
                let key = TableKey(pointer: pointer)

                switch sourceOccurrencesTable[key] {
                case .none:
                    sourceOccurrencesTable[key] = .unique(index: flattenSourceIndex)

                case .unique(let otherIndex)?:
                    let reference = IndicesReference([otherIndex, flattenSourceIndex])
                    sourceOccurrencesTable[key] = .duplicate(reference: reference)

                case .duplicate(let reference)?:
                    reference.push(flattenSourceIndex)
                }
            }

            // Record the target index and the source index that the element having the same identifier.
            for targetSectionIndex in contiguousTargetSections.indices {
                let targetElements = contiguousTargetSections[targetSectionIndex]

                for targetElementIndex in targetElements.indices {
                    var targetIdentifier = targetElements[targetElementIndex].differenceIdentifier
                    let key = TableKey(pointer: &targetIdentifier)

                    switch sourceOccurrencesTable[key] {
                    case .none:
                        break

                    case .unique(let flattenSourceIndex)?:
                        let sourceElementPath = flattenSourceElementPaths[flattenSourceIndex]
                        let targetElementPath = ElementPath(element: targetElementIndex, section: targetSectionIndex)

                        if case .none = sourceElementTraces[sourceElementPath].reference {
                            targetElementReferences[targetElementPath] = sourceElementPath
                            sourceElementTraces[sourceElementPath].reference = targetElementPath
                        }

                    case .duplicate(let reference)?:
                        if let flattenSourceIndex = reference.next() {
                            let sourceElementPath = flattenSourceElementPaths[flattenSourceIndex]
                            let targetElementPath = ElementPath(element: targetElementIndex, section: targetSectionIndex)
                            targetElementReferences[targetElementPath] = sourceElementPath
                            sourceElementTraces[sourceElementPath].reference = targetElementPath
                        }
                    }
                }
            }
        }

        // Record the element deletions.
        for sourceSectionIndex in contiguousSourceSections.indices {
            // Should not calculate the element deletions in the deleted section.
            guard case .some = sectionResult.metadata.sourceTraces[sourceSectionIndex].reference else {
                continue
            }

            var offsetByDelete = 0
            var firstStageElements = ContiguousArray<Element>()
            let sourceElements = contiguousSourceSections[sourceSectionIndex]

            for sourceElementIndex in sourceElements.indices {
                let sourceElementPath = ElementPath(element: sourceElementIndex, section: sourceSectionIndex)

                sourceElementTraces[sourceElementPath].deleteOffset = offsetByDelete

                // If the element target section is recorded as insertion, record its element path as deletion.
                if let targetElementPath = sourceElementTraces[sourceElementPath].reference,
                    case .some = sectionResult.metadata.targetReferences[targetElementPath.section] {
                    let sourceElement = contiguousSourceSections[sourceElementPath]
                    firstStageElements.append(sourceElement)
                    continue
                }

                elementDeleted.append(sourceElementPath)
                sourceElementTraces[sourceElementPath].isTracked = true
                offsetByDelete += 1
            }

            let firstStageSection = Section(source: sourceSections[sourceSectionIndex], elements: firstStageElements)
            firstStageSections.append(firstStageSection)
        }

        // Record the element updates/moves/insertions.
        for targetSectionIndex in contiguousTargetSections.indices {
            // Should not calculate the element updates/moves/insertions in the inserted section.
            guard let sourceSectionIndex = sectionResult.metadata.targetReferences[targetSectionIndex] else {
                secondStageSections.append(targetSections[targetSectionIndex])
                thirdStageSections.append(targetSections[targetSectionIndex])
                continue
            }

            var untrackedSourceIndex: Int? = 0
            let targetElements = contiguousTargetSections[targetSectionIndex]

            let sectionDeleteOffset = sectionResult.metadata.sourceTraces[sourceSectionIndex].deleteOffset

            let secondStageSection = firstStageSections[sourceSectionIndex - sectionDeleteOffset]
            secondStageSections.append(secondStageSection)

            var thirdStageElements = ContiguousArray<Element>()
            thirdStageElements.reserveCapacity(targetElements.count)

            for targetElementIndex in targetElements.indices {
                untrackedSourceIndex = untrackedSourceIndex.flatMap { index in
                    sourceElementTraces[sourceSectionIndex].suffix(from: index).index { !$0.isTracked }
                }

                let targetElementPath = ElementPath(element: targetElementIndex, section: targetSectionIndex)
                let targetElement = contiguousTargetSections[targetElementPath]

                // If the element source section is recorded as deletion, record its element path as insertion.
                guard let sourceElementPath = targetElementReferences[targetElementPath],
                    let movedSourceSectionIndex = sectionResult.metadata.sourceTraces[sourceElementPath.section].reference else {
                        thirdStageElements.append(targetElement)
                        elementInserted.append(targetElementPath)
                        continue
                }

                sourceElementTraces[sourceElementPath].isTracked = true

                let sourceElement = contiguousSourceSections[sourceElementPath]
                thirdStageElements.append(sourceElement)

                if !targetElement.isContentEqual(to: sourceElement) {
                    elementUpdated.append(targetElementPath)
                }

                if sourceElementPath.section != sourceSectionIndex || sourceElementPath.element != untrackedSourceIndex {
                    let deleteOffset = sourceElementTraces[sourceElementPath].deleteOffset
                    let moveSourceElementPath = ElementPath(element: sourceElementPath.element - deleteOffset, section: movedSourceSectionIndex)
                    elementMoved.append((source: moveSourceElementPath, target: targetElementPath))
                }
            }

            let thirdStageSection = Section(source: secondStageSection, elements: thirdStageElements)
            thirdStageSections.append(thirdStageSection)
        }

        var changesets = ContiguousArray<Changeset<Collection>>()

        // The 1st stage changeset.
        // - Includes:
        //   - section deletes
        //   - element deletes
        if !sectionResult.deleted.isEmpty || !elementDeleted.isEmpty {
            changesets.append(
                Changeset(
                    data: Collection(firstStageSections),
                    sectionDeleted: sectionResult.deleted,
                    elementDeleted: elementDeleted
                )
            )
        }

        // The 2st stage changeset.
        // - Includes:
        //   - section inserts
        //   - section moves
        if !sectionResult.inserted.isEmpty || !sectionResult.moved.isEmpty {
            changesets.append(
                Changeset(
                    data: Collection(secondStageSections),
                    sectionInserted: sectionResult.inserted,
                    sectionMoved: sectionResult.moved
                )
            )
        }

        // The 3st stage changeset.
        // - Includes:
        //   - element inserts
        //   - element moves
        if !elementInserted.isEmpty || !elementMoved.isEmpty {
            changesets.append(
                Changeset(
                    data: Collection(thirdStageSections),
                    elementInserted: elementInserted,
                    elementMoved: elementMoved
                )
            )
        }

        // The 3st stage changeset.
        // - Includes:
        //   - section updates
        //   - element updates
        if !sectionResult.updated.isEmpty || !elementUpdated.isEmpty {
            changesets.append(
                Changeset(
                    data: target,
                    sectionUpdated: sectionResult.updated,
                    elementUpdated: elementUpdated
                )
            )
        }

        // Set the target to `data` of the last stage.
        if !changesets.isEmpty {
            let index = changesets.index(before: changesets.endIndex)
            changesets[index].data = target
        }

        self.init(changesets)
    }
}

/// The shared algorithm to calculate differences between two linear collections.
@discardableResult
private func differentiate<E: Differentiable, I>(
    source: ContiguousArray<E>,
    target: ContiguousArray<E>,
    trackTargetIndexAsUpdated: Bool,
    mapIndex: (Int) -> I,
    remainedInTarget: ((E) -> Void)? = nil
    ) -> DifferentiateResult<I> {
    var deleted = [I]()
    var inserted = [I]()
    var updated = [I]()
    var moved = [(source: I, target: I)]()

    var sourceTraces = ContiguousArray<Trace<Int>>()
    var targetReferences = ContiguousArray<Int?>(repeating: nil, count: target.count)
    var sourceIdentifiers = ContiguousArray<E.DifferenceIdentifier>()

    sourceIdentifiers.reserveCapacity(source.count)
    sourceTraces.reserveCapacity(source.count)

    for sourceElement in source {
        sourceTraces.append(Trace())
        sourceIdentifiers.append(sourceElement.differenceIdentifier)
    }

    sourceIdentifiers.withUnsafeBufferPointer { bufferPointer in
        // The pointer and the table key are for optimization.
        var sourceOccurrencesTable = [TableKey<E.DifferenceIdentifier>: Occurrence](minimumCapacity: source.count * 2)

        // Record the index where the element was found in source collection into occurrences table.
        for sourceIndex in sourceIdentifiers.indices {
            let pointer = bufferPointer.baseAddress!.advanced(by: sourceIndex)
            let key = TableKey(pointer: pointer)

            switch sourceOccurrencesTable[key] {
            case .none:
                sourceOccurrencesTable[key] = .unique(index: sourceIndex)

            case .unique(let otherIndex)?:
                let reference = IndicesReference([otherIndex, sourceIndex])
                sourceOccurrencesTable[key] = .duplicate(reference: reference)

            case .duplicate(let reference)?:
                reference.push(sourceIndex)
            }
        }

        // Record the target index and the source index that the element having the same identifier.
        for targetIndex in target.indices {
            var targetIdentifier = target[targetIndex].differenceIdentifier
            let key = TableKey(pointer: &targetIdentifier)

            switch sourceOccurrencesTable[key] {
            case .none:
                break

            case .unique(let sourceIndex)?:
                if case .none = sourceTraces[sourceIndex].reference {
                    targetReferences[targetIndex] = sourceIndex
                    sourceTraces[sourceIndex].reference = targetIndex
                }

            case .duplicate(let reference)?:
                if let sourceIndex = reference.next() {
                    targetReferences[targetIndex] = sourceIndex
                    sourceTraces[sourceIndex].reference = targetIndex
                }
            }
        }
    }

    var offsetByDelete = 0
    var untrackedSourceIndex: Int? = 0

    // Record the deletions.
    for sourceIndex in source.indices {
        sourceTraces[sourceIndex].deleteOffset = offsetByDelete

        if let targetIndex = sourceTraces[sourceIndex].reference {
            let targetElement = target[targetIndex]
            remainedInTarget?(targetElement)
        } else {
            deleted.append(mapIndex(sourceIndex))
            sourceTraces[sourceIndex].isTracked = true
            offsetByDelete += 1
        }
    }

    // Record the updates/moves/insertions.
    for targetIndex in target.indices {
        untrackedSourceIndex = untrackedSourceIndex.flatMap { index in
            sourceTraces.suffix(from: index).index { !$0.isTracked }
        }

        if let sourceIndex = targetReferences[targetIndex] {
            sourceTraces[sourceIndex].isTracked = true

            let sourceElement = source[sourceIndex]
            let targetElement = target[targetIndex]

            if !targetElement.isContentEqual(to: sourceElement) {
                updated.append(mapIndex(trackTargetIndexAsUpdated ? targetIndex : sourceIndex))
            }

            if sourceIndex != untrackedSourceIndex {
                let deleteOffset = sourceTraces[sourceIndex].deleteOffset
                moved.append((source: mapIndex(sourceIndex - deleteOffset), target: mapIndex(targetIndex)))
            }
        } else {
            inserted.append(mapIndex(targetIndex))
        }
    }

    return DifferentiateResult(
        deleted: deleted,
        inserted: inserted,
        updated: updated,
        moved: moved,
        metadata: (sourceTraces: sourceTraces, targetReferences: targetReferences)
    )
}

/// A set of changes and metadata as a result of calculating differences in linear collection.
private struct DifferentiateResult<Index> {
    typealias Metadata = (sourceTraces: ContiguousArray<Trace<Int>>, targetReferences: ContiguousArray<Int?>)

    let deleted: [Index]
    let inserted: [Index]
    let updated: [Index]
    let moved: [(source: Index, target: Index)]
    let metadata: Metadata

    init(
        deleted: [Index] = [],
        inserted: [Index] = [],
        updated: [Index] = [],
        moved: [(source: Index, target: Index)] = [],
        metadata: Metadata
        ) {
        self.deleted = deleted
        self.inserted = inserted
        self.updated = updated
        self.moved = moved
        self.metadata = metadata
    }
}

/// A set of informations in middle of difference calculation.
private struct Trace<Index> {
    var reference: Index?
    var deleteOffset = 0
    var isTracked = false
}

/// The occurrences of element.
private enum Occurrence {
    case unique(index: Int)
    case duplicate(reference: IndicesReference)
}

/// A mutable reference to indices of elements.
private final class IndicesReference {
    private var indices: ContiguousArray<Int>
    private var position = 0

    init(_ indices: ContiguousArray<Int>) {
        self.indices = indices
    }

    func push(_ index: Int) {
        indices.append(index)
    }

    func next() -> Int? {
        guard position < indices.endIndex else {
            return nil
        }
        defer { position += 1 }
        return indices[position]
    }
}

/// Dictionary key using UnsafePointer for performance optimization.
private struct TableKey<T: Hashable>: Hashable {
    let hashValue: Int
    private let pointer: UnsafePointer<T>

    init(pointer: UnsafePointer<T>) {
        self.hashValue = pointer.pointee.hashValue
        self.pointer = pointer
    }

    static func == (lhs: TableKey, rhs: TableKey) -> Bool {
        return lhs.hashValue == rhs.hashValue
            && (lhs.pointer.distance(to: rhs.pointer) == 0 || lhs.pointer.pointee == rhs.pointer.pointee)
    }
}

private extension MutableCollection where Element: MutableCollection, Index == Int, Element.Index == Int {
    subscript(path: ElementPath) -> Element.Element {
        get { return self[path.section][path.element] }
        set { self[path.section][path.element] = newValue }
    }
}
