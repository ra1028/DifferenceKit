import DifferenceKit

typealias Sections = [ArraySection<SectionData, CellData>]

extension Array where Element == ArraySection<SectionData, CellData> {
    var totalCellDataCount: Int {
        return reduce(0) { $0 + $1.elements.count }
    }
} 
