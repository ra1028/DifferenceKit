import XCTest
import DifferenceKit

#if canImport(AppKit)
import AppKit

@available(OSX 10.11, *)
class NSCollectionViewTests: XCTestCase {
    
    fileprivate var window: NSWindow!
    fileprivate var collectionView: NSCollectionView!
    fileprivate var dataProvider: DataProvider!
    
    override func setUp() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        collectionView = NSCollectionView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        window.contentView?.addSubview(collectionView)
        
        dataProvider = DataProvider()
        collectionView.dataSource = dataProvider
        
        super.setUp()
    }
    
    override func tearDown() {
        window = nil
        collectionView = nil
        dataProvider = nil
        
        super.tearDown()
    }
    
    func testCollectionViewReloadInvokeCompletionWhenDataChanged() {
        let data1 = [1, 2, 3]
        dataProvider.data = data1
        
        collectionView.reloadData()
        
        let data2 = [1, 2, 3, 4]
        let reloadExpectation = expectation(description: "collectionView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        collectionView.reload(using: changset, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 3.0)
    }
    
    func testCollectionViewReloadInvokeCompletionWhenNewDataIsEmpty() {
        let data1 = [Int]()
        dataProvider.data = data1
        
        collectionView.reloadData()
        
        let data2 = [Int]()
        let reloadExpectation = expectation(description: "collectionView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        collectionView.reload(using: changset, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 3.0)
    }
    
}

@available(OSX 10.11, *)
extension NSCollectionViewTests {
    
    fileprivate final class DataProvider : NSObject, NSCollectionViewDataSource {
        var data: [Int] = []
        
        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            return data.count
        }
        
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            return NSCollectionViewItem()
        }
    }
    
}

#endif
