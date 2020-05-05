import XCTest
import DifferenceKit

final class MeasurementTestCase: XCTestCase {
    func testMeasureAlgorithmForLinearCollection() {
        let source = Array(1...100000)
        let target = source.mutated(removeAt: IndexSet(10000..<20000), insertAt: IndexSet(30000..<40000))

        measure {
            _ = StagedChangeset(source: source, target: target)
        }
    }

    func testMeasureAlgorithmForSectionedCollection() {
        let source: [ArraySection<D, Int>] = D.allCases.enumerated().map { o, d in
            let lowerBound = o * 30000 + 1
            let upperBound = lowerBound + 20000
            return ArraySection(model: d, elements: Array(lowerBound...upperBound))
        }
        let target = source.map { section in
            ArraySection(
                model: section.model,
                elements: section.elements.mutated(removeAt: IndexSet(2000..<5000), insertAt: IndexSet(5000..<8000))
            )
        }

        measure {
            _ = StagedChangeset(source: source, target: target)
        }
    }
}

private extension RangeReplaceableCollection where Element == Int {
    func mutated(removeAt: IndexSet, insertAt: IndexSet) -> Self {
        var subject = ContiguousArray(self)
        var max = subject.max(by: <) ?? 0

        for range in removeAt.rangeView.reversed() {
            subject.removeSubrange(range)
        }

        for range in insertAt.rangeView {
            let lowerBound = max + 1
            let upperBound = lowerBound + range.count
            max += range.count
            subject.insert(contentsOf: lowerBound..<upperBound, at: range.lowerBound)
        }

        return Self(subject)
    }
}
