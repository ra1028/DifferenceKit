import UIKit

final class HomeViewController: UITableViewController {
    struct Component {
        var title: String
        var subtitle: String
        var initViewController: () -> UIViewController
    }

    private let components = [
        Component(title: "Shuffle Emojis", subtitle: "Shuffle sectioned Emojis in UICollectionView", initViewController: EmojiViewController.init),
        Component(title: "Header Footer Section", subtitle: "Update header/footer by reload section in UITableView", initViewController: HeaderFooterViewController.init),
        Component(title: "Random", subtitle: "Random diff in UICollectionView", initViewController: RandomViewController.init)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
        tableView.tableFooterView = UIView()
        tableView.register(cellType: HomeCell.self)
    }
}

extension HomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeCell = tableView.dequeueReusableCell(for: indexPath)
        let component = components[indexPath.row]
        cell.titleLabel.text = component.title
        cell.subtitleLabel.text = component.subtitle
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = components[indexPath.row].initViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
