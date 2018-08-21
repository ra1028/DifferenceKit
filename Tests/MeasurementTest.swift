import XCTest
import DifferenceKit

final class MeasurementTestCase: XCTestCase {
    func testMeasureAlgorithmForLinearCollection() {
        let source = Array(1...10000)
        let target = source.mutated(removeAt: IndexSet(1000..<2000), insertAt: IndexSet(3000..<4000))

        measure {
            _ = StagedChangeset(source: source, target: target)
        }
    }

    func testMeasureAlgorithmForSectionedCollection() {
        let source: [ArraySection<D, Int>] = D.allCases.enumerated().map { o, d in
            let lowerBound = o * 3000 + 1
            let upperBound = lowerBound + 2000
            return ArraySection(model: d, elements: Array(lowerBound...upperBound))
        }
        let target = source.map { section in
            ArraySection(
                model: section.model,
                elements: section.elements.mutated(removeAt: IndexSet(200..<500), insertAt: IndexSet(500..<800))
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
