import UIKit

final class EmojiCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 7)
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHidden ? 0.2 : 1 }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            guard let self = self else { return }
            self.contentView.layer.shadowOpacity = self.isFocused ? 0.3 : 0
            self.contentView.layer.transform = self.isFocused ? CATransform3DMakeScale(1.1, 1.1, 1) : CATransform3DIdentity
            self.layer.zPosition = self.isFocused ? 1 : 0
        })
    }
}
