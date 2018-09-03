#if canImport(UIKit)
import UIKit

final class Section: UICollectionReusableView {
    var sectionData: SectionData?
    
    static let reuseIdentifier = "Section.reuseIdentifier"
    static let kind = UICollectionElementKindSectionHeader
}
#endif
