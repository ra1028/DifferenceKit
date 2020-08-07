import XCTest
import DifferenceKit

final class DifferenceIdentifierSubscriptTests: XCTestCase {
    private struct Counter: ContentIdentifiable, Equatable {
        let differenceIdentifier: String
        var count: Int
    }
    
    func testSubscriptSetterExist() {
        var d1 = [
            Counter(differenceIdentifier: "first", count: 0),
            Counter(differenceIdentifier: "second", count: 0),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        let d2 = [
            Counter(differenceIdentifier: "first", count: 0),
            Counter(differenceIdentifier: "second", count: 100),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        
        d1[id: "second"]?.count = 100
        XCTAssertEqual(d1, d2)
    }
    
    func testSubscriptSetterNotExist() {
        var d1 = [
            Counter(differenceIdentifier: "first", count: 0),
            Counter(differenceIdentifier: "second", count: 0),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        let d2 = [
            Counter(differenceIdentifier: "first", count: 0),
            Counter(differenceIdentifier: "second", count: 0),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        
        d1[id: "forth"]?.count = 100
        XCTAssertEqual(d1, d2)
    }
    
    func testSubscriptGetterExist() {
        let d1 = [
            Counter(differenceIdentifier: "first", count: 100),
            Counter(differenceIdentifier: "second", count: 0),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        
        XCTAssertEqual(d1[id: "first"]?.count, 100)
    }
    
    func testSubscriptGetterNotExist() {
        let d1 = [
            Counter(differenceIdentifier: "first", count: 0),
            Counter(differenceIdentifier: "second", count: 0),
            Counter(differenceIdentifier: "third", count: 0)
        ]
        
        XCTAssertEqual(d1[id: "forth"], nil)
    }
}
