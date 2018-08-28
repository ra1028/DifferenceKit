import XCTest
import UIKit

private let collectionSize = 100
private let iterationsCount = 100

final class DifferenceKitStressTests: XCTestCase {
    func test_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges_1() {
        performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges()
    }
    
    func test_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges_2() {
        performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges()
    }
    
    func test_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges_3() {
        performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges()
    }
    
    func test_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges_4() {
        performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges()
    }
    
    func test_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges_5() {
        performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges()
    }
    
    // MARK: - Private
    private func performTest_differenceKit_doesNotCrashUICollectionView_duringStressCollectionChanges() {
        let expectations = (0..<iterationsCount).map {
            expectation(description: "async expectation of iteration \($0)")
        }
        
        performTests(expectations: expectations)
        waitForExpectations(timeout: 60)
    }
    
    private func performTests(expectations: [XCTestExpectation]) {
        performTest(
            index: 0,
            expectations: expectations,
            previousCellDataList: []
        )
    }
    
    private func performTest(
        index: Int,
        expectations: [XCTestExpectation],
        previousCellDataList: [CellData])
    {
        guard index < expectations.count else { return }
        
        autoreleasepool {
            print("testing iteration \(index)")
            
            let cellDataGenerator = CellDataGenerator()
            
            // Given
            let cellDataGeneratorResult: CellDataGeneratorResult
            if index == 0 {
                cellDataGeneratorResult = cellDataGenerator
                    .generateCellData(count: collectionSize)
            } else if index == iterationsCount / 2 {
                // Special case: applying no changes to original data
                cellDataGeneratorResult = cellDataGenerator
                    .performNoActionsOnCellData(
                        previousCellDataList
                    )
            } else {
                cellDataGeneratorResult = cellDataGenerator
                    .performRandomActionsOnCellData(
                        previousCellDataList,
                        minimumCountAfterActions: collectionSize / 10,
                        maximumCountAfterActions: collectionSize * 10
                )
            }
            
            print("  from \(cellDataGeneratorResult.from.count), to: \(cellDataGeneratorResult.to.count).")
            
            print("  deletes \(cellDataGeneratorResult.deletes), "
                + "inserts: \(cellDataGeneratorResult.inserts), "
                + "moves \(cellDataGeneratorResult.moves), "
                + "updates: \(cellDataGeneratorResult.updates)."
            )
            
            // When
            let collectionViewUpdater = CollectionViewUpdater()
            collectionViewUpdater.updateCollectionView(
                from: cellDataGeneratorResult.from,
                to: cellDataGeneratorResult.to,
                completion: { [weak self] result in
                    // Then
                    switch result {
                    case let .exception(exception):
                        XCTFail("Failed to update collection view using DifferenceKit. exception: \(exception)")
                    case .noUpdateRequired:
                        break
                    case let .success(visibleCellDataList, expectedCellDataList):
                        XCTAssert(
                            visibleCellDataList.count == expectedCellDataList.count,
                            "Update the layout to fit all cells in the screen"
                        )
                        
                        let zippedCellDataLists = zip(visibleCellDataList, expectedCellDataList)
                        for (index, (visibleCellData, expectedCellData)) in zippedCellDataLists.enumerated() {
                            XCTAssert(
                                visibleCellData.isContentEqual(to: expectedCellData),
                                "visible cell data and expected cell data are not in sync at index: \(index)"
                            )
                        }
                    }
                    
                    print("")
                    
                    collectionViewUpdater.cleanUp()
                    
                    expectations[index].fulfill()
                    
                    DispatchQueue.main.async {
                        self?.performTest(
                            index: index + 1,
                            expectations: expectations,
                            previousCellDataList: cellDataGeneratorResult.to
                        )
                    }
                }
            )
        }
    }
}
