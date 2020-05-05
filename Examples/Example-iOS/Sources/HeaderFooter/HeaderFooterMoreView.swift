import UIKit

final class HeaderFooterMoreView: UITableViewHeaderFooterView, NibReusable {
    var onMorePressed: (() -> Void)?

    @IBAction func handleMorePressed() {
        onMorePressed?()
    }
}
