import UIKit
import DifferenceKit
import Foundation

enum CollectionViewUpdaterResult {
    case exception(NSException)
    case noUpdateRequired // diff is empty
    case success(visibleSections: Sections, expectedSections: Sections)
}

final class CollectionViewUpdater: NSObject, UICollectionViewDataSource {
    // MARK: - State
    private var sections = Sections() // for UICollectionViewDataSource
    private var collectionView: UICollectionView?
    private var window: UIWindow?
    
    // MARK: - Internal
    func updateCollectionView(
        from: Sections,
        to: Sections,
        completion: @escaping (CollectionViewUpdaterResult) -> ())
    {
        let collectionView = makeAndReloadCollectionViewWith(sections: from)
        
        let diff = StagedChangeset(
            source: from,
            target: to
        )
        
        performBatchUpdates(
            of: collectionView,
            sections: to,
            diff: diff,
            completion: completion
        )
    }
    
    func cleanUp() {
        sections = []
        collectionView?.dataSource = nil
        collectionView?.removeFromSuperview()
        collectionView = nil
        window = nil
    }

    // MARK: - Private
    private func makeAndReloadCollectionViewWith(
        sections: Sections)
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
        layout.headerReferenceSize = CGSize(width: 1, height: 1) // To fit all headers in the screen 
        
        let collectionView = UICollectionView(frame: window.frame, collectionViewLayout: layout)
        self.collectionView = collectionView
        window.addSubview(collectionView)
        
        self.sections = sections
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.register(Section.self, forSupplementaryViewOfKind: Section.kind, withReuseIdentifier: Section.reuseIdentifier)
        collectionView.reloadData()
        
        return collectionView
    }
    
    private func performBatchUpdates(
        of collectionView: UICollectionView,
        sections: Sections,
        diff: StagedChangeset<Sections>,
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
                collectionView.reload(using: diff) { sections in 
                    self.sections = sections
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
                    let visibleSectionIndexPaths = collectionView
                        .indexPathsForVisibleSupplementaryElements(ofKind: Section.kind).sortedAscendingly()
                    
                    var visibleSections: Sections = visibleSectionIndexPaths.map {
                        let section = collectionView.supplementaryView(forElementKind: Section.kind, at: $0) as! Section
                        return ArraySection(model: section.sectionData!, elements: [])
                    }
                    
                    let visibleCellIndexPaths = collectionView
                        .indexPathsForVisibleItems.sortedAscendingly()
                    
                    visibleCellIndexPaths.forEach {
                        let cell = collectionView.cellForItem(at: $0) as! Cell
                        visibleSections[$0.section].elements.append(cell.cellData!)
                    }
                    
                    completion(
                        .success(
                            visibleSections: visibleSections,
                            expectedSections: sections
                        )
                    )
                }
            }
        )
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.cellData = sections[indexPath.section].elements[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Section.reuseIdentifier, for: indexPath) as! Section
        section.sectionData = sections[indexPath.section].model
        return section
    }
}

extension Array where Element == IndexPath {
    func sortedAscendingly() -> [IndexPath] {
        return sorted {
            if $0.section < $1.section { return true }
            if $0.section > $1.section { return false }
            return $0.row < $1.row
        }
    }
}
