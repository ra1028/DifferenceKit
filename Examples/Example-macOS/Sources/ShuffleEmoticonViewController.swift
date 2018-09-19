import Cocoa
import DifferenceKit

final class ShuffleEmoticonViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var tableView: NSTableView!
    
    private var data = (0x1F600...0x1F647).compactMap { UnicodeScalar($0).map(String.init) }
    private var dataInput: [String] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            collectionView.reload(using: changeset) { data in
                self.data = data
            }
            tableView.reload(using: changeset, with: .effectFade) { data in
                self.data = data
            }
        }
    }

    @IBAction func shufflePress(_ button: NSButton) {
        dataInput.shuffle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(EmoticonCollectionViewItem.self, forItemWithIdentifier: EmoticonCollectionViewItem.itemIdentifier)
    }
}

extension ShuffleEmoticonViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: EmoticonCollectionViewItem.itemIdentifier, for: indexPath) as! EmoticonCollectionViewItem
        item.emoticon = data[indexPath.item]
        return item
    }
}

extension ShuffleEmoticonViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSTableCellView.itemIdentifier, owner: tableView) as! NSTableCellView
        view.textField?.stringValue = data[row]
        return view
    }
}

private extension NSTableCellView {
    static var itemIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(String(describing: self))
    }
}

private final class EmoticonCollectionViewItem: NSCollectionViewItem {
    static var itemIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(String(describing: self))
    }

    var emoticon: String {
        get { return _textField.stringValue }
        set { _textField.stringValue = newValue }
    }

    private let _textField = NSTextField()

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 60, height: 54))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _textField.font = .systemFont(ofSize: 40)
        _textField.alignment = .center
        _textField.isEditable = false

        _textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(_textField)

        let constraints = [
            _textField.topAnchor.constraint(equalTo: view.topAnchor),
            _textField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _textField.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
