import Foundation
import DifferenceKit
import Differentiator
import FlexibleDiff
import IGListKit
import DeepDiff
import Differ
import Dwifft

let runner = BenchmarkRunner(
    Benchmark(name: "DifferenceKit") { data in
        return {
            _ = StagedChangeset(source: data.source, target: data.target)
        }
    },
    Benchmark(name: "RxDataSources") { data in
        let model = UUID()
        let initialSections = [AnimatableSectionModel(model: model, items: data.source)]
        let finalSections = [AnimatableSectionModel(model: model, items: data.target)]

        return {
            _ = try! Diff.differencesForSectionedView(initialSections: initialSections, finalSections: finalSections)
        }
    },
    Benchmark(name: "IGListKit") { data in
        let oldArray = data.source.map { $0 as NSUUID }
        let newArray = data.target.map { $0 as NSUUID }

        return {
            _ = ListDiff(oldArray: oldArray, newArray: newArray, option: .equality)
        }
    },
    Benchmark(name: "FlexibleDiff") { data in
        return {
            _ = FlexibleDiff.Changeset(previous: data.source, current: data.target, identifier: { $0 }, areEqual: ==)
        }
    },
    Benchmark(name: "DeepDiff") { data in
        return {
            _ = DeepDiff.diff(old: data.source, new: data.target)
        }
    },
    Benchmark(name: "Differ") { data in
        return {
            _ = data.source.diff(data.target) as Differ.Diff
        }
    },
    Benchmark(name: "Dwifft") { data in
        return {
            _ = Dwifft.diff(data.source, data.target)
        }
    }
)

runner.run(with: BenchmarkData(
    count: 5000,
    deleteRange: 2000..<3000,
    insertRange: 3000..<4000,
    shuffleRange: 0..<200
))

runner.run(with: BenchmarkData(
    count: 100000,
    deleteRange: 20000..<30000,
    insertRange: 30000..<40000,
    shuffleRange: 0..<2000
))
