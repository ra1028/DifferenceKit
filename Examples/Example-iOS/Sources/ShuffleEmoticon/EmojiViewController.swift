import UIKit
import DifferenceKit

final class EmojiViewController: UIViewController {
    enum SectionID: Differentiable, CaseIterable {
        case first, second, third
    }

    typealias Section = ArraySection<SectionID, String>

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

        title = "Emoji"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: EmojiCell.self)

        refresh()
    }

    @IBAction func refresh() {
        let ids = SectionID.allCases
        let Emojis = (0x1F600...0x1F647).compactMap { UnicodeScalar($0).map(String.init) }
        let splitedCount = Int((Double(Emojis.count) / Double(ids.count)).rounded(.up))

        dataInput = ids.enumerated().map { offset, model in
            let start = offset * splitedCount
            let end = min(start + splitedCount, Emojis.endIndex)
            let Emojis = Emojis[start..<end]
            return Section(model: model, elements: Emojis)
        }
    }

    @IBAction func shuffleAllEmojis() {
        var flattenEmojis = ArraySlice(dataInput.flatMap { $0.elements })
        flattenEmojis.shuffle()

        dataInput = dataInput.map { section in
            var section = section
            section.elements = Array(flattenEmojis.prefix(section.elements.count))
            flattenEmojis.removeFirst(section.elements.count)
            return section
        }
    }

    @IBAction func shuffleSections() {
        dataInput.shuffle()
    }

    func remove(at indexPath: IndexPath) {
        dataInput[indexPath.section].elements.remove(at: indexPath.item)
    }
}

extension EmojiViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EmojiCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.label.text = data[indexPath.section].elements[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        remove(at: indexPath)
    }
}
