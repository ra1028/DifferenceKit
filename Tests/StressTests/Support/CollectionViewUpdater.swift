import XCTest
import UIKit
import DifferenceKit
import Foundation

enum CollectionViewUpdaterResult {
    case exception(NSException)
    case noUpdateRequired // diff is empty
    case success(visibleCellDataList: [CellData], expectedCellDataList: [CellData])
}

final class CollectionViewUpdater: NSObject, UICollectionViewDataSource {
    // MARK: - State
    private var cellData = [CellData]() // for UICollectionViewDataSource
    private var collectionView: UICollectionView?
    private var window: UIWindow?
    
    // MARK: - Internal
    func updateCollectionView(
        from: [CellData],
        to: [CellData],
        completion: @escaping (CollectionViewUpdaterResult) -> ())
    {
        let collectionView = makeAndReloadCollectionViewWith(cellData: from)
        
        let diff = StagedChangeset(
            source: from,
            target: to
        )
        
        performBatchUpdates(
            of: collectionView,
            cellDataList: to,
            diff: diff,
            completion: completion
        )
    }
    
    func cleanUp() {
        cellData = []
        collectionView?.dataSource = nil
        collectionView?.removeFromSuperview()
        collectionView = nil
        window = nil
    }

    // MARK: - Private
    private func makeAndReloadCollectionViewWith(
        cellData: [CellData])
        -> UICollectionView
    {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.layer.speed = 100 // Speed up the animations
        self.window = window
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 1, height: 1) // To fit all cells in the screen 
        layout.minimumInteritemSpacing = 0.001
        layout.minimumLineSpacing = 0.001
        
        let collectionView = UICollectionView(frame: window.frame, collectionViewLayout: layout)
        self.collectionView = collectionView
        window.addSubview(collectionView)
        
        self.cellData = cellData
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.reloadData()
        
        return collectionView
    }
    
    private func performBatchUpdates(
        of collectionView: UICollectionView,
        cellDataList: [CellData],
        diff: StagedChangeset<[CellData]>,
        completion: @escaping (CollectionViewUpdaterResult) -> ())
    {
        guard !diff.isEmpty else {
            // If we apply an empty diff to a collection view, then for some reason
            // `collectionView.indexPathsForVisibleItems` and `collectionView.visibleCells` return empty arrays,
            // even if `collectionView.numberOfItems(inSection:)` returns a non empty number.
            // So we cannot perform normal assertions as in `CollectionViewUpdaterResult.success`
            return completion(.noUpdateRequired)
        }
        
        var catchedException: NSException?
        
        ObjCExceptionCatcher.tryClosure(
            tryClosure: {
                collectionView.reload(using: diff) { cellData in 
                    self.cellData = cellData
                }
            },
            catchClosure: { exception in
                catchedException = exception
            },
            finallyClosure: {
                if let catchedException = catchedException {
                    completion(
                        .exception(catchedException)
                    )
                } else {
                    let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row }
                    
                    let visibleCellDataList: [CellData] = visibleIndexPaths.map {
                        let cell = collectionView.cellForItem(at: $0) as! Cell
                        return cell.cellData!
                    }
                    
                    completion(
                        .success(
                            visibleCellDataList: visibleCellDataList,
                            expectedCellDataList: cellDataList
                        )
                    )
                }
            }
        )
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.cellData = cellData[indexPath.row]
        return cell
    }
}
