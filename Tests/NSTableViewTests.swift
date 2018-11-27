import XCTest
import DifferenceKit

#if canImport(AppKit)
import AppKit

class NSTableViewTests: XCTestCase {
    
    fileprivate var window: NSWindow!
    fileprivate var tableView: NSTableView!
    fileprivate var dataProvider: DataProvider!
    
    override func setUp() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        tableView = NSTableView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        window.contentView?.addSubview(tableView)
        
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
        let reloadExpectation = expectation(description: "tableView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        tableView.reload(using: changset, with: .effectFade, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 3.0)
    }
    
    func testTableViewReloadInvokeCompletionWhenNewDataIsEmpty() {
        let data1 = [Int]()
        dataProvider.data = data1
        
        tableView.reloadData()
        
        let data2 = [Int]()
        let reloadExpectation = expectation(description: "tableView reload with completion")
        
        let changset = StagedChangeset(source: data1, target: data2)
        tableView.reload(using: changset, with: .effectFade, setData: { data in
            dataProvider.data = data
        }, completion: {
            reloadExpectation.fulfill()
        })
        
        wait(for: [reloadExpectation], timeout: 3.0)
    }
    
}

extension NSTableViewTests {
    
    fileprivate final class DataProvider : NSObject, NSTableViewDataSource {
        
        var data: [Int] = []
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return data.count
        }
    }
    
}

#endif
