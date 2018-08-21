import UIKit
import DifferenceKit

private enum EmoticonSectionID: Differentiable {
    case first, second, third

    // FIXME: This is not required after Swift 4.2. Use CaseIterable.
    static var allCases: [EmoticonSectionID] {
        return [.first, .second, .third]
    }
}

private typealias EmoticonSection = ArraySection<EmoticonSectionID, String>

final class ShuffleEmoticonViewController: UIViewController {
    private let collectionView: UICollectionView
    private var data = [EmoticonSection]()

    private var dataInput: [EmoticonSection] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            collectionView.reload(using: changeset) { data in
                self.data = data
            }
        }
    }

    private func remove(at indexPath: IndexPath) {
        dataInput[indexPath.section].elements.remove(at: indexPath.item)
    }

    @objc private func shuffleSections() {
        dataInput.shuffle()
    }

    @objc private func shuffleAllEmoticons() {
        var flattenEmoticons = ArraySlice(dataInput.flatMap { $0.elements })
        flattenEmoticons.shuffle()

        dataInput = dataInput.map { section in
            var section = section
            section.elements = Array(flattenEmoticons.prefix(section.elements.count))
            flattenEmoticons.removeFirst(section.elements.count)
            return section
        }
    }

    @objc private func refresh() {
        let ids = EmoticonSectionID.allCases
        let emoticons = (0x1F600...0x1F647).compactMap { UnicodeScalar($0).map(String.init) }
        let splitedCount = Int((Double(emoticons.count) / Double(ids.count)).rounded(.up))

        dataInput = ids.enumerated().map { offset, model in
            let start = offset * splitedCount
            let end = min(start + splitedCount, emoticons.endIndex)
            let emoticons = emoticons[start..<end]
            return EmoticonSection(model: model, elements: emoticons)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        super.init(nibName: nil, bundle: nil)

        title = "Shuffle Emoticons"
        view.backgroundColor = .white

        let column: CGFloat = 6
        let spacing: CGFloat = 4
        let sectionSpacing: CGFloat = 6
        let screenWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenWidth - (sectionSpacing * 2) - (spacing * (column - 1))) / column
        let itemHeight = itemWidth * 0.55
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.sectionInset = UIEdgeInsets(top: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing, right: sectionSpacing)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 30)

        collectionView.contentInset.top = sectionSpacing
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmoticonCollectionViewCell.self, forCellWithReuseIdentifier: EmoticonCollectionViewCell.reuseIdentifier)
        collectionView.register(TextCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TextCollectionReusableView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Shuffle All Emoticons", style: .plain, target: self, action: #selector(shuffleAllEmoticons)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Shuffle Sections", style: .plain, target: self, action: #selector(shuffleSections)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShuffleEmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonCollectionViewCell.reuseIdentifier, for: indexPath) as! EmoticonCollectionViewCell
        let emoticon = data[indexPath.section].elements[indexPath.item]
        cell.emoticon = emoticon
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TextCollectionReusableView.reuseIdentifier, for: indexPath) as! TextCollectionReusableView
        view.text = "Section \(data[indexPath.section].model)"
        return view
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        remove(at: indexPath)
    }
}

private final class EmoticonCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: self)

    var emoticon: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        contentView.layer.cornerRadius = 8

        contentView.addSubview(label)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.2 : 1 }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class TextCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: self)

    var text: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.05)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// FIXME: This extension is not required after Swift 4.2
// https://github.com/apple/swift/blob/master/stdlib/public/core/CollectionAlgorithms.swift
private extension MutableCollection {
    mutating func shuffle() {
        let count = self.count
        guard count > 1 else { return }

        var amount = count
        var currentIndex = startIndex

        while amount > 1 {
            let random = Int(arc4random_uniform(UInt32(amount)))
            amount -= 1
            swapAt(currentIndex, index(currentIndex, offsetBy: numericCast(random)))
            formIndex(after: &currentIndex)
        }
    }
}
