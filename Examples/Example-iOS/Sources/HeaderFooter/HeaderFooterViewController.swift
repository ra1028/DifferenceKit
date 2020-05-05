import UIKit
import DifferenceKit

final class HeaderFooterViewController: UITableViewController {
    typealias Section = ArraySection<HeaderFooterSectionModel, String>

    private var data = [Section]()

    private var dataInput: [Section] {
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
        let section = Section(model: model, elements: allTexts.prefix(7))
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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Header Footer"
        tableView.allowsSelection = false

        tableView.register(cellType: HeaderFooterPlainCell.self)
        tableView.register(viewType: HeaderFooterMoreView.self)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
}

extension HeaderFooterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HeaderFooterPlainCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = data[indexPath.section].elements[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].model.headerTitle
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard data[section].model.hasFooter else { return nil }

        let view: HeaderFooterMoreView = tableView.dequeueReusableHeaderFooterView()
        view.onMorePressed = { [weak self] in
            self?.showMore(in: section)
        }

        return view
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].model.hasFooter ? 44 : 0
    }
}
