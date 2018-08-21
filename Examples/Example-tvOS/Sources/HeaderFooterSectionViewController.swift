import UIKit
import DifferenceKit

private struct HeaderFooterSectionModel: Differentiable {
    var id: Int
    var hasFooter: Bool

    var headerTitle: String {
        return "Section \(id)"
    }

    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: HeaderFooterSectionModel) -> Bool {
        return hasFooter == source.hasFooter
    }
}

private typealias HeaderFooterSection = ArraySection<HeaderFooterSectionModel, String>

final class HeaderFooterSectionViewController: UITableViewController {
    private var data = [HeaderFooterSection]()

    private var dataInput: [HeaderFooterSection] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            tableView.reload(using: changeset, with: .fade) { data in
                self.data = data
            }
        }
    }

    private let allTexts = (0x0041...0x005A).compactMap { UnicodeScalar($0).map(String.init) }

    @objc private func refresh() {
        let model = HeaderFooterSectionModel(id: 0, hasFooter: true)
        let section = HeaderFooterSection(model: model, elements: allTexts.prefix(7))
        dataInput = [section]
    }

    private func showMore(in sectionIndex: Int) {
        var section = dataInput[sectionIndex]
        let texts = allTexts.dropFirst(section.elements.count).prefix(7)
        section.elements.append(contentsOf: texts)
        section.model.hasFooter = section.elements.count < allTexts.count
        dataInput[sectionIndex] = section

        let lastIndex = section.elements.index(before: section.elements.endIndex)
        let lastIndexPath = IndexPath(row: lastIndex, section: sectionIndex)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    init() {
        super.init(style: .plain)

        title = "Header Footer Section"
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.register(HeaderFooterSectionFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterSectionFooterView.reuseIdentifier)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderFooterSectionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = data[indexPath.section].elements[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].model.headerTitle
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard data[section].model.hasFooter else { return nil }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterSectionFooterView.reuseIdentifier) as! HeaderFooterSectionFooterView
        view.morePressedAction = { [weak self] in
            self?.showMore(in: section)
        }
        return view
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].model.hasFooter ? 80 : 0
    }
}

private final class HeaderFooterSectionFooterView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: UITableViewCell.self)

    var morePressedAction: (() -> Void)?

    private let moreButton = UIButton(type: .system)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(moreButton)
        moreButton.setTitle("More", for: .normal)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.addTarget(self, action: #selector(morePressed), for: .primaryActionTriggered)

        let constraints = [
            moreButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            moreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            moreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @objc private func morePressed() {
        morePressedAction?()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UITableViewCell {
    static let reuseIdentifier = String(describing: UITableViewCell.self)
}
