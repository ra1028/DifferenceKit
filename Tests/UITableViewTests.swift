import XCTest
import DifferenceKit

#if canImport(UIKit)
import UIKit

class UITableViewTests: XCTestCase {
    
    fileprivate var window: UIWindow!
    fileprivate var tableView: UITableView!
    fileprivate var dataProvider: DataProvider!
    
    override func setUp() {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.addSubview(tableView)
        
        dataProvider = DataProvider()
        tableView.dataSource = dataProvider
        
        super.setUp()
    }
    
    override func tearDown() {
        window = nil
        tableView = nil
        dataProvider = nil
        
        super.tearDown()
    }
    
    func testTableViewReloadInvokeCompletionWhenDataChanged() {
        let data1 = [1, 2, 3]
        dataProvider.data = data1
        
        tableView.reloadData()
        
        let data2 = [1, 2, 3, 4]
        let reloadExpectation = expectation(description: "TableView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        tableView.reload(using: changset, with: .automatic, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 2.0)
    }
    
    func testTableViewReloadInvokeCompletionWhenNewDataIsEmpty() {
        let data1 = [Int]()
        dataProvider.data = data1
        
        tableView.reloadData()
        
        let data2 = [Int]()
        let reloadExpectation = expectation(description: "TableView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        tableView.reload(using: changset, with: .automatic, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 2.0)
    }
    
}

extension UITableViewTests {
    
    fileprivate final class DataProvider : NSObject, UITableViewDataSource {
        
        var data: [Int] = []
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
        
    }
    
}

#endif
