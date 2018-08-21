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

        let column: CGFloat = 12
        let spacing: CGFloat = 8
        let sectionSpacing: CGFloat = 12
        let screenWidth = UIScreen.main.bounds.size.width
        let itemWidth = (screenWidth - (sectionSpacing * 2) - (spacing * (column - 1))) / column
        let itemHeight = itemWidth * 0.55
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.sectionInset = UIEdgeInsets(top: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing, right: sectionSpacing)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 44)

        collectionView.backgroundColor = .clear
        collectionView.contentInset.top = sectionSpacing
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmoticonCollectionViewCell.self, forCellWithReuseIdentifier: EmoticonCollectionViewCell.reuseIdentifier)
        collectionView.register(TextCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TextCollectionReusableView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

        let buttonComponents: [(title: String, action: Selector)] = [
            (title: "Shuffle All Emoticons", action: #selector(shuffleAllEmoticons)),
            (title: "Shuffle Sections", action: #selector(shuffleSections))
        ]

        let buttons: [UIButton] = buttonComponents.map { component in
            let button = UIButton(type: .system)
            button.setTitle(component.title, for: .normal)
            button.addTarget(self, action: component.action, for: .primaryActionTriggered)
            return button
        }

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let constraints = [
            stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 7)
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

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            guard let `self` = self else { return }
            self.contentView.layer.shadowOpacity = self.isFocused ? 0.3 : 0
            self.contentView.layer.transform = self.isFocused ? CATransform3DMakeScale(1.1, 1.1, 1) : CATransform3DIdentity
            self.layer.zPosition = self.isFocused ? 1 : 0
        })
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
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 24)
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
