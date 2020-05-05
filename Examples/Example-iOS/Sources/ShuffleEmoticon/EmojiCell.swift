import UIKit

final class EmojiCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        label.layer.cornerRadius = 8
    }
}
