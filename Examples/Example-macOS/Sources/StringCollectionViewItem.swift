import AppKit

class StringCollectionViewItem: NSCollectionViewItem {
    let label = NSTextField()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 60, height: 54))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.font = NSFont.systemFont(ofSize: 40)
        view.addSubview(label)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
