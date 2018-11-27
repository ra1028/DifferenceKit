import XCTest
import DifferenceKit

#if canImport(UIKit)
import UIKit

class UICollectionViewTests: XCTestCase {
    
    fileprivate var window: UIWindow!
    fileprivate var collectionView: UICollectionView!
    fileprivate var dataProvider: DataProvider!
    
    override func setUp() {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        window.addSubview(collectionView)
        
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
        let reloadExpectation = expectation(description: "CollectionView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        collectionView.reload(using: changset, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 2.0)
    }
    
    func testCollectionViewReloadInvokeCompletionWhenNewDataIsEmpty() {
        let data1 = [Int]()
        dataProvider.data = data1
        
        collectionView.reloadData()
        
        let data2 = [Int]()
        let reloadExpectation = expectation(description: "CollectionView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        collectionView.reload(using: changset, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 2.0)
    }
    
}

extension UICollectionViewTests {
    
    fileprivate final class DataProvider : NSObject, UICollectionViewDataSource {
        
        var data: [Int] = []
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return data.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        
    }
    
}

#endif
