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
        let model = UUID()
        let source = [ArraySection(model: model, elements: data.source)]
        let target = [ArraySection(model: model, elements: data.target)]

        return {
            _ = StagedChangeset(source: source, target: target)
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
        let model = UUID()
        let previous = [ArraySection(model: model, elements: data.source)]
        let current = [ArraySection(model: model, elements: data.target)]

        return {
            _ = SectionedChangeset(
                previous: previous,
                current: current,
                sectionIdentifier: { $0.model },
                areMetadataEqual: { $0.model == $1.model },
                items: { $0.elements },
                itemIdentifier: { $0 },
                areItemsEqual: ==
            )
        }
    },
    Benchmark(name: "DeepDiff") { data in
        return {
            _ = DeepDiff.diff(old: data.source, new: data.target)
        }
    },
    Benchmark(name: "Differ") { data in
        return {
            _ = data.source.extendedDiff(data.target)
        }
    },
    Benchmark(name: "Dwifft") { data in
        let section = UUID()
        let lhs = SectionedValues([(section, data.source)])
        let rhs = SectionedValues([(section, data.target)])

        return {
            _ = Dwifft.diff(lhs: lhs, rhs: rhs)
        }
    }
)

runner.run(with: BenchmarkData(count: 5000, deleteRange: 2000..<3000, insertRange: 3000..<4000))
runner.run(with: BenchmarkData(count: 100000, deleteRange: 20000..<30000, insertRange: 30000..<40000))
