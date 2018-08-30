#if canImport(UIKit)
import XCTest
import UIKit

final class DifferenceKitStressTests: XCTestCase {
    // MARK: - One dimentional collection
    func test_differenceKit_doesNotCrashOneDimensionalUICollectionView_duringStressCollectionChanges_1() {
        performTestForOneDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashOneDimensionalUICollectionView_duringStressCollectionChanges2() {
        performTestForOneDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashOneDimensionalUICollectionView_duringStressCollectionChanges3() {
        performTestForOneDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashOneDimensionalUICollectionView_duringStressCollectionChanges4() {
        performTestForOneDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashOneDimensionalUICollectionView_duringStressCollectionChanges5() {
        performTestForOneDimensionalCollection()
    }
    
    // MARK: - Two dimentional collection
    func test_differenceKit_doesNotCrashTwoDimensionalCollectionUICollectionView_duringStressCollectionChanges1() {
        performTestForTwoDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashTwoDimensionalCollectionUICollectionView_duringStressCollectionChanges2() {
        performTestForTwoDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashTwoDimensionalCollectionUICollectionView_duringStressCollectionChanges3() {
        performTestForTwoDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashTwoDimensionalCollectionUICollectionView_duringStressCollectionChanges4() {
        performTestForTwoDimensionalCollection()
    }
    
    func test_differenceKit_doesNotCrashTwoDimensionalCollectionUICollectionView_duringStressCollectionChanges5() {
        performTestForTwoDimensionalCollection()
    }
    
    // MARK: - Private
    private func performTestForOneDimensionalCollection() {
        performTest(
            sectionsCountRange: 1..<2, // single section means one dimensional collection
            cellsCountRange: 0..<250,
            iterationsCount: 100
        )
    }
    
    private func performTestForTwoDimensionalCollection() {
        performTest(
            sectionsCountRange: 0..<20, // many sections mean two dimensional collection
            cellsCountRange: 0..<250,
            iterationsCount: 100
        )
    }
    
    private func performTest(
        sectionsCountRange: Range<Int>,
        cellsCountRange: Range<Int>,
        iterationsCount: Int)
    {
        let expectations = (0..<iterationsCount).map {
            expectation(description: "async expectation of iteration \($0)")
        }
        
        performTests(
            iterationsCount: iterationsCount,
            expectations: expectations,
            sectionsCountRange: sectionsCountRange,
            cellsCountRange: cellsCountRange
        )
        
        waitForExpectations(timeout: 60)
    }
    
    private func performTests(
        iterationsCount: Int,
        expectations: [XCTestExpectation],
        sectionsCountRange: Range<Int>,
        cellsCountRange: Range<Int>)
    {
        print("")
        
        performTest(
            iteration: 0,
            iterationsCount: expectations.count,
            expectations: expectations,
            sectionsCountRange: sectionsCountRange,
            cellsCountRange: cellsCountRange,
            previousCollection: []
        )
    }
    
    private func performTest(
        iteration: Int,
        iterationsCount: Int,
        expectations: [XCTestExpectation],
        sectionsCountRange: Range<Int>,
        cellsCountRange: Range<Int>,
        previousCollection: Collection)
    {
        guard iteration < iterationsCount, expectations.count == iterationsCount else { return }
        
        autoreleasepool {
            print("testing iteration \(iteration)")
            
            let collectionMutator = CollectionMutator()
            
            // Given
            let collectionMutatation: CollectionMutatation
            if iteration == 0 {
                collectionMutatation = collectionMutator
                    .generateCollection(
                        sectionsCount: sectionsCountRange.middle,
                        cellsCount: cellsCountRange.middle
                    )
            } else if iteration == iterationsCount / 2 {
                // Special case: applying no changes to original data
                collectionMutatation = collectionMutator
                    .performNoActionsOnCollection(
                        previousCollection
                    )
            } else {
                collectionMutatation = collectionMutator
                    .performRandomActionsOnCollection(
                        previousCollection,
                        recommendedSectionsCountRange: sectionsCountRange,
                        recommendedTotalCellsCountRange: cellsCountRange
                    )
            }
            
            print("  sections: from \(collectionMutatation.from.count) "
                + "to: \(collectionMutatation.to.count).")
            
            print("  sections: deletes \(collectionMutatation.sectionDeletes), "
                + "inserts: \(collectionMutatation.sectionInserts), "
                + "moves \(collectionMutatation.sectionMoves), "
                + "updates: \(collectionMutatation.sectionUpdates).")
            
            print("  cells:    from \(collectionMutatation.from.totalCellDataCount) "
                + "to: \(collectionMutatation.to.totalCellDataCount).")
            
            print("  cells:    deletes \(collectionMutatation.cellDeletes), "
                + "inserts: \(collectionMutatation.cellInserts), "
                + "moves \(collectionMutatation.cellMoves), "
                + "updates: \(collectionMutatation.cellUpdates)."
            )
            
            // When
            let collectionViewUpdater = CollectionViewUpdater()
            collectionViewUpdater.updateCollectionView(
                from: collectionMutatation.from,
                to: collectionMutatation.to,
                completion: { [weak self] result in
                    // Then
                    switch result {
                    case let .exception(exception):
                        XCTFail("Failed to update collection view using DifferenceKit. exception: \(exception)")
                    case .noUpdateRequired:
                        break
                    case let .success(visibleCollection, expectedCollection):
                        XCTAssert(
                            visibleCollection.sectionsCount == expectedCollection.sectionsCount,
                            "Update the layout to fit all sections in the screen"
                        )
                        XCTAssert(
                            visibleCollection.totalCellDataCount == expectedCollection.totalCellDataCount,
                            "Update the layout to fit all cells in the screen"
                        )
                        
                        let zippedCollections = zip(visibleCollection, expectedCollection)
                        for (sectionIndex, (visibleSection, expectedSection)) in zippedCollections.enumerated() {
                            XCTAssert(
                                visibleSection.model.isContentEqual(to: expectedSection.model),
                                "visible section data and expected section data are not in sync at section index: \(sectionIndex)"
                            )
                            
                            let zippedCells = zip(visibleSection.elements, expectedSection.elements)
                            for (cellIndex, (visibleCellData, expectedCellData)) in zippedCells.enumerated() {
                                XCTAssert(
                                    visibleCellData.isContentEqual(to: expectedCellData),
                                    "visible cell data and expected section data are not in sync at cell index: \(cellIndex)"
                                )
                            }
                        }
                    }
                    
                    print("")
                    
                    collectionViewUpdater.cleanUp()
                    
                    expectations[iteration].fulfill()
                    
                    DispatchQueue.main.async {
                        // Perform next iteration
                        self?.performTest(
                            iteration: iteration + 1,
                            iterationsCount: iterationsCount,
                            expectations: expectations,
                            sectionsCountRange: sectionsCountRange,
                            cellsCountRange: cellsCountRange,
                            previousCollection: collectionMutatation.to
                        )
                    }
                }
            )
        }
    }
}
#endif
