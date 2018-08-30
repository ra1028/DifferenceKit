import UIKit

final class HomeViewController: UITableViewController {
    private let data: [(cell: UITableViewCell, initViewController: () -> UIViewController)]

    init() {
        let tableComponents: [(title: String, subtitle: String, initViewController: () -> UIViewController)] = [
            (title: "Shuffle Emoticons", subtitle: "Shuffle sectioned emoticons in UICollectionView", initViewController: ShuffleEmoticonViewController.init),
            (title: "Header Footer Section", subtitle: "Update header/footer by reload section in UITableView", initViewController: HeaderFooterSectionViewController.init),
            (title: "Random", subtitle: "Random diff in UICollectionView", initViewController: RandomViewController.init)
        ]

        data = tableComponents.map { component in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = component.title
            cell.detailTextLabel?.text = component.subtitle
            return (cell: cell, initViewController: component.initViewController)
        }

        super.init(style: .plain)

        title = "Home"
        view.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return data[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = data[indexPath.row].initViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
