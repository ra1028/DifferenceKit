import UIKit
import DifferenceKit

final class RandomViewController: UIViewController {
    private typealias Section = ArraySection<RandomModel, RandomModel>

    @IBOutlet private weak var collectionView: UICollectionView!

    private var data = [Section]()
    private var dataInput: [Section] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            collectionView.reload(using: changeset) { data in
                self.data = data
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Random"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(refresh))

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: RandomPlainCell.self)
        collectionView.register(viewType: RandomLabelView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }

    @objc private func refresh() {
        let defaultSourceSectionCount = 20
        let defaultSourceElementCount = 20

        func randomSection() -> ArraySection<RandomModel, RandomModel> {
            let elements = (0..<defaultSourceElementCount).map { _ in RandomModel() }
            return ArraySection(model: RandomModel(), elements: elements)
        }

        guard !data.isEmpty else {
            dataInput = (0..<defaultSourceSectionCount).map { _ in randomSection() }
            return
        }

        let source = data
        var target = source

        let sourceSectionCount = source.count
        let deleteSectionCount = Int.random(in: 0..<sourceSectionCount / 4)
        let deletedSourceSectionCount = sourceSectionCount - deleteSectionCount
        let updateSectionCount = Int.random(in: 0..<deletedSourceSectionCount / 4)
        let moveSectionCount = Int.random(in: 0..<deletedSourceSectionCount / 4)
        let minInsertCount = defaultSourceSectionCount > sourceSectionCount ? deleteSectionCount : 0
        let insertSectionCount = Int.random(in: minInsertCount..<sourceSectionCount / 4)
        let targetSectionCount = deletedSourceSectionCount + insertSectionCount

        let deleteSectionIndices = (0..<deleteSectionCount).map { i in Int.random(in: 0..<sourceSectionCount - i) }
        let updateSectionIndices = (0..<updateSectionCount).map { _ in Int.random(in: 0..<deletedSourceSectionCount) }
        let moveSectionIndexPairs = (0..<moveSectionCount).map { _ in (source: Int.random(in: 0..<deletedSourceSectionCount), target: Int.random(in: 0..<deletedSourceSectionCount)) }
        let insertSectionIndices = (0..<insertSectionCount).map { i in Int.random(in: 0..<deletedSourceSectionCount + i) }

        for index in deleteSectionIndices {
            target.remove(at: index)
        }

        for index in target.indices {
            let sourceCount = target[index].elements.count
            let deleteCount = Int.random(in: 0..<sourceCount / 4)
            let deletedSourceCount = sourceCount - deleteCount
            let updateCount = Int.random(in: 0..<deletedSourceCount / 4)
            let moveCount = Int.random(in: 0..<deletedSourceCount / 4)
            let insertCount = Int.random(in: 0..<sourceCount / 4)

            let deleteIndices = (0..<deleteCount).map { i in Int.random(in: 0..<sourceCount - i) }
            let updateIndices = (0..<updateCount).map { _ in Int.random(in: 0..<deletedSourceCount) }
            let moveIndexPairs = (0..<moveCount).map { _ in (source: Int.random(in: 0..<deletedSourceCount), target: Int.random(in: 0..<deletedSourceCount)) }
            let insertIndices = (0..<insertCount).map { i in Int.random(in: 0..<deletedSourceCount + i) }

            for elementIndex in deleteIndices {
                target[index].elements.remove(at: elementIndex)
            }

            for elementIndex in updateIndices {
                target[index].elements[elementIndex].isUpdated.toggle()
            }

            for pair in moveIndexPairs {
                target[index].elements.swapAt(pair.source, pair.target)
            }

            for elementIndex in insertIndices {
                target[index].elements.insert(RandomModel(), at: elementIndex)
            }
        }

        for index in updateSectionIndices {
            target[index].model.isUpdated.toggle()
        }

        for pair in moveSectionIndexPairs {
            target.swapAt(pair.source, pair.target)
        }

        for index in insertSectionIndices {
            target.insert(randomSection(), at: index)
        }

        let elementMoveAcrossSectionCount = Int.random(in: 0..<targetSectionCount * 2)
        for _ in (0..<elementMoveAcrossSectionCount) {
            func randomIndexPath() -> IndexPath {
                let sectionIndex = Int.random(in: 0..<targetSectionCount)
                let elementIndex = Int.random(in: 0..<target[sectionIndex].elements.count)
                return IndexPath(item: elementIndex, section: sectionIndex)
            }
            let sourceIndexPath = randomIndexPath()
            let targetIndexPath = randomIndexPath()
            target[sourceIndexPath.section].elements[sourceIndexPath.item] = target[targetIndexPath.section].elements[targetIndexPath.item]
            target[targetIndexPath.section].elements[targetIndexPath.item] = target[sourceIndexPath.section].elements[sourceIndexPath.item]
        }

        dataInput = target
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
}

extension RandomViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RandomPlainCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = data[indexPath.section].elements[indexPath.item]
        cell.contentView.backgroundColor = model.isUpdated ? .cyan : .orange
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let model = data[indexPath.section].model
        let view: RandomLabelView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
        view.label.text = "Section ID: \(model.id)"
        view.label.textColor = model.isUpdated ? .red : .darkText
        return view
    }
}
