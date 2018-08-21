import UIKit
import DifferenceKit

extension String: Differentiable {}

public final class TableViewController: UITableViewController {
    public var refreshAction: (() -> Void)?

    public var dataInput: [ArraySection<String, String>] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            tableView.reload(using: changeset, with: .fade) { data in
                self.data = data
            }
        }
    }

    private var data = [ArraySection<String, String>]()

    public init() {
        super.init(style: .grouped)
        tableView.sectionHeaderHeight = 30
        tableView.sectionFooterHeight = 0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func refresh() {
        refreshAction?()
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].elements.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = data[indexPath.section].elements[indexPath.row]
        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].model
    }
}
