#if canImport(UIKit)
import DifferenceKit

typealias Collection = [ArraySection<SectionData, CellData>]

extension Array where Element == ArraySection<SectionData, CellData> {
    var totalCellDataCount: Int {
        return reduce(0) { $0 + $1.elements.count }
    }
    
    var sectionsCount: Int {
        return count
    }
}
#endif
