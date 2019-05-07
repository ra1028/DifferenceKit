import UIKit

final class RandomPlainCell: UICollectionViewCell, Reusable {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2
    }
}
