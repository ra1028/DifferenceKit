import Cocoa
import DifferenceKit

extension String: Differentiable { }

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var tableView: NSTableView!
    
    var strings: [String] = {
        var strings: [String] = []
        for i in 0..<40 {
            strings.append(ViewController.randomEmoji)
        }
        return strings
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(StringCollectionViewItem.self, forItemWithIdentifier: .init("StringItem"))
    }
    
    @IBAction func shufflePress(_ sender: Any) {
        let shuffled = strings.shuffled()
        let changeSet = StagedChangeset(source: strings, target: shuffled)
        collectionView.reload(using: changeSet, setData: { _ in })
        
        tableView.reload(using: changeSet, with: [], setData: { self.strings = $0 })
    }

    static var randomEmoji: String {
        let range = [UInt32](0x1F601...0x1F64F)
        let ascii = range[Int(drand48() * (Double(range.count)))]
        let emoji = UnicodeScalar(ascii)?.description
        return emoji!
    }
}

extension ViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return strings.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("StringItem"), for: indexPath) as! StringCollectionViewItem
        item.label.stringValue = strings[indexPath.item]
        return item
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: .init("StringCell"), owner: tableView) as! NSTableCellView
        view.textField?.stringValue = strings[row]
        return view
    }
}
