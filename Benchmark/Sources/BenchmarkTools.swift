import DifferenceKit
import Differentiator
import IGListKit
import DeepDiff

extension UUID: Differentiable {}

extension UUID: IdentifiableType {
    public var identity: UUID {
        return self
    }
}

extension UUID: DiffAware {
    public var diffId: Int {
        return hashValue
    }

    public static func compareContent(_ a: UUID, _ b: UUID) -> Bool {
        return a == b
    }
}

extension NSUUID: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? NSUUID else {
            return false
        }
        return self == other
    }
}

struct BenchmarkData {
    var source: [UUID]
    var target: [UUID]
    var deleteRange: CountableRange<Int>
    var insertRange: CountableRange<Int>
    var shuffleRange: CountableRange<Int>

    init(count: Int, deleteRange: CountableRange<Int>, insertRange: CountableRange<Int>, shuffleRange: CountableRange<Int>) {
        source = (0..<count).map { _ in UUID() }
        target = source
        self.deleteRange = deleteRange
        self.insertRange = insertRange
        self.shuffleRange = shuffleRange

        target.removeSubrange(deleteRange)
        target.insert(contentsOf: insertRange.map { _ in UUID() }, at: insertRange.lowerBound)
        target[shuffleRange].shuffle()
    }
}

struct Benchmark {
    var name: String
    var prepare: (BenchmarkData) -> () -> Void

    func measure(with data: BenchmarkData) -> CFAbsoluteTime {
        let action = prepare(data)
        let start = CFAbsoluteTimeGetCurrent()
        action()
        let end = CFAbsoluteTimeGetCurrent()

        return end - start
    }
}

struct BenchmarkRunner {
    var benchmarks: [Benchmark]

    init(_ benchmarks: Benchmark...) {
        self.benchmarks = benchmarks
    }

    func run(with data: BenchmarkData) {
        let sourceCount = String.localizedStringWithFormat("%d", data.source.count)
        let deleteCount = String.localizedStringWithFormat("%d", data.deleteRange.count)
        let insertCount = String.localizedStringWithFormat("%d", data.insertRange.count)
        let shuffleCount = String.localizedStringWithFormat("%d", data.shuffleRange.count)

        let maxLength = benchmarks.lazy
            .map { $0.name.count }
            .max() ?? 0

        let empty = String(repeating: " ", count: maxLength)
        let timeTitle = "Time(sec)".padding(toLength: maxLength, withPad: " ", startingAt: 0)
        let leftAlignSpacer = ":" + String(repeating: "-", count: maxLength - 1)
        let rightAlignSpacer = String(repeating: "-", count: maxLength - 1) + ":"

        print("#### - From \(sourceCount) elements to \(deleteCount) deleted, \(insertCount) inserted and \(shuffleCount) shuffled")
        print()
        print("""
            |\(empty)|\(timeTitle)|
            |\(leftAlignSpacer)|\(rightAlignSpacer)|
            """)

        for benchmark in benchmarks {
            let paddingName = benchmark.name.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            print("|\(paddingName)|", terminator: "")

            let result = benchmark.measure(with: data)
            let paddingTime = String(format: "`%.4f`", result).padding(toLength: maxLength, withPad: " ", startingAt: 0)
            print("\(paddingTime)|")
        }

        print()
    }
}
