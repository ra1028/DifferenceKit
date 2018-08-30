import UIKit

final class TextCollectionReusableView: UICollectionReusableView {
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
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
