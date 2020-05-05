import Cocoa

final class ShuffleEmoticonCollectionViewItem: NSCollectionViewItem {
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
