import DifferenceKit

final class SectionsMutator {
    func generate(
        sectionsCount: Int,
        cellsCount: Int)
        -> SectionsMutatation
    {
        let sectionDataList = generateSectionData(count: sectionsCount)
        let cellDataList = generateCellData(count: cellsCount)
        let sections = combineIntoSections(sectionDataList, cellDataList)
        
        return SectionsMutatation(
            sectionDeletes: 0,
            sectionInserts: sections.count,
            sectionMoves: 0,
            sectionUpdates: 0,
            cellDeletes: 0,
            cellInserts: sections.totalCellDataCount,
            cellMoves: 0,
            cellUpdates: 0,
            from: [],
            to: sections
        )
    }
    
    private func generateCellData(count: Int) -> [CellData] {
        return (0 ..< count).map { _ in
            return CellData(
                differenceIdentifier: UUID(),
                title: UUID().uuidString,
                subtitle: UUID().uuidString
            )
        }
    }
    
    private func generateSectionData(count: Int) -> [SectionData] {
        return (0 ..< count).map { _ in
            return SectionData(
                differenceIdentifier: UUID(),
                title: UUID().uuidString
            )
        }
    }
    
    
    private func combineIntoSections(
        _ sectionDataList: [SectionData],
        _ cellDataList: [CellData])
        -> Sections
    {
        var result = Sections()
        var cellDataList = cellDataList
        
        for (index, sectionData) in sectionDataList.enumerated() where cellDataList.count != 0 {
            let sectionCapacity = (index == sectionDataList.endIndex)
                ? Int.random() % cellDataList.count
                : cellDataList.count
            
            let sectionCellDataList = Array(cellDataList.prefix(sectionCapacity))
            cellDataList = Array(cellDataList.dropFirst(sectionCapacity))
            
            let section = ArraySection(model: sectionData, elements: sectionCellDataList)
            result.append(section)
        }
        
        return result
    }
    
    func performRandomActionsOnSections(
        _ oldSections: Sections,
        recommendedSectionsCountRange: Range<Int>,
        recommendedTotalCellsCountRange: Range<Int>)
        -> SectionsMutatation
    {
        var newSections = oldSections
        
        let willDeleteSections = oldSections.count > recommendedSectionsCountRange.lowerBound
        let willInsertSections = oldSections.count < recommendedSectionsCountRange.upperBound
        
        var sectionDeletes = 0
        var sectionInserts = 0
        var sectionMoves = 0
        var sectionUpdates = 0
        var cellDeletes = 0
        var cellDeletesDuringSectionDeletes = 0
        var cellInserts = 0
        var cellMoves = 0
        var cellUpdates = 0
        
        if willDeleteSections {
            sectionDeletes = Int.random() % recommendedSectionsCountRange.middle
            deleteSections(from: &newSections, count: &sectionDeletes, deletedCellDataCount: &cellDeletesDuringSectionDeletes)
        }
        
        if willInsertSections {
            sectionInserts = Int.random() % recommendedSectionsCountRange.middle
            insertSections(into: &newSections, count: sectionInserts)
        }
        
        sectionMoves = Int.random() % recommendedSectionsCountRange.oneThird
        moveSections(in: &newSections, count: &sectionMoves)
        
        sectionUpdates = Int.random() % recommendedSectionsCountRange.oneThird
        updateSections(in: &newSections, count: &sectionUpdates)
        
        // Decide wether or not to insert / delete cells depending on the updated section's capacities
        // (use `newSections` instead of `oldSections)
        let willDeleteCells = newSections.totalCellDataCount > recommendedTotalCellsCountRange.lowerBound
        let willInsertCells = newSections.totalCellDataCount < recommendedTotalCellsCountRange.upperBound
        
        if willDeleteCells {
            cellDeletes = Int.random() % recommendedTotalCellsCountRange.oneThird
            deleteCells(from: &newSections, count: &cellDeletes)
        }
        
        if willInsertCells {
            cellInserts = Int.random() % recommendedTotalCellsCountRange.oneThird
            insertCells(into: &newSections, count: &cellInserts)
        }
        
        cellMoves = Int.random() % recommendedTotalCellsCountRange.oneFourth
        moveCells(in: &newSections, count: &cellMoves)
        
        cellUpdates = Int.random() % recommendedTotalCellsCountRange.oneFourth
        updateCells(in: &newSections, count: &cellUpdates)
        
        assert(oldSections.count - sectionDeletes + sectionInserts == newSections.count)
        assert(oldSections.totalCellDataCount - cellDeletes - cellDeletesDuringSectionDeletes + cellInserts == newSections.totalCellDataCount)
        
        return SectionsMutatation(
            sectionDeletes: sectionDeletes,
            sectionInserts: sectionInserts,
            sectionMoves: sectionMoves,
            sectionUpdates: sectionUpdates,
            cellDeletes: cellDeletes + cellDeletesDuringSectionDeletes,
            cellInserts: cellInserts,
            cellMoves: cellMoves,
            cellUpdates: cellUpdates,
            from: oldSections,
            to: newSections
        )
    }
    
    func performNoActionsOnSections(_ sections: Sections)
        -> SectionsMutatation
    {
        return SectionsMutatation(
            sectionDeletes: 0,
            sectionInserts: 0,
            sectionMoves: 0,
            sectionUpdates: 0,
            cellDeletes: 0,
            cellInserts: 0,
            cellMoves: 0,
            cellUpdates: 0,
            from: sections,
            to: sections
        )
    }
    
    private func insertCells(into sections: inout Sections, count: inout Int) {
        let initialCellDataCount = sections.totalCellDataCount
        var reallyInsertedCellDataCount = 0
        defer {
            count = reallyInsertedCellDataCount
            assert(sections.totalCellDataCount == initialCellDataCount + reallyInsertedCellDataCount)
        }
        
        guard sections.count != 0 else { return }
        
        for _ in 0 ..< count {
            let cellData = CellData(
                differenceIdentifier: UUID(),
                title: UUID().uuidString,
                subtitle: UUID().uuidString
            )
            
            let randomSectionIndex = Int.random() % sections.count
            var randomSection = sections[randomSectionIndex]
            
            if randomSection.elements.isEmpty {
                randomSection.elements.append(cellData)
            } else {
                let randomCellDataIndex = Int.random() % randomSection.elements.count
                randomSection.elements.insert(cellData, at: randomCellDataIndex)
            }
            
            sections[randomSectionIndex] = randomSection
            
            reallyInsertedCellDataCount += 1
        }
    }
    
    private func deleteCells(from sections: inout Sections, count: inout Int) {
        let initialCellDataCount = sections.totalCellDataCount
        var reallyDeletedCellDataCount = 0
        defer {
            count = reallyDeletedCellDataCount
            assert(sections.totalCellDataCount == initialCellDataCount - reallyDeletedCellDataCount)
        }
        
        for _ in 0 ..< count {
            guard sections.totalCellDataCount != 0 else { return }
            
            var sectionIndexes = Array((0..<sections.count))
            
            while !sectionIndexes.isEmpty {
                let randomSectionIndex = Int.random() % sectionIndexes.count
                sectionIndexes.remove(at: randomSectionIndex)
                
                var randomSection = sections[randomSectionIndex]
                if randomSection.elements.count > 0 {
                    let randomCellDataIndex = Int.random() % randomSection.elements.count
                    randomSection.elements.remove(at: randomCellDataIndex)
                    sections[randomSectionIndex] = randomSection
                    reallyDeletedCellDataCount += 1
                }
            }
        }
    }
    
    private func moveCells(in sections: inout Sections, count: inout Int) {
        let initialCellDataCount = sections.totalCellDataCount
        var reallyMovedCellDataCount = 0
        defer {
            count = reallyMovedCellDataCount
            assert(sections.totalCellDataCount == initialCellDataCount)
        }
        
        guard sections.totalCellDataCount != 0 else { return }
        
        for _ in 0 ..< count {
            let randomFromSectionIndex = Int.random() % sections.count
            let randomToSectionIndex = Int.random() % sections.count
            
            var randomFromSection = sections[randomFromSectionIndex]
            var randomToSection = sections[randomToSectionIndex]
            
            if randomFromSection.elements.count == 0 || randomToSection.elements.count == 0 { continue }
            
            let randomFromCellDataIndex = Int.random() % randomFromSection.elements.count
            let movedCellData = randomFromSection.elements.remove(at: randomFromCellDataIndex)
            if randomFromSectionIndex == randomToSectionIndex {
                randomToSection.elements.remove(at: randomFromCellDataIndex)
            }
            sections[randomFromSectionIndex] = randomFromSection
            
            if randomToSection.elements.isEmpty {
                randomToSection.elements.append(movedCellData)
            } else {
                let randomToCellDataIndex = Int.random() % randomToSection.elements.count
                randomToSection.elements.insert(movedCellData, at: randomToCellDataIndex)
            }
            sections[randomToSectionIndex] = randomToSection
            
            reallyMovedCellDataCount += 1
        }
    }
    
    private func updateCells(in sections: inout Sections, count: inout Int) {
        let initialCellDataCount = sections.totalCellDataCount
        var reallyUpdatedCellDataCount = 0
        defer {
            count = reallyUpdatedCellDataCount
            assert(sections.totalCellDataCount == initialCellDataCount)
        }
        
        guard sections.totalCellDataCount != 0 else { return }
        
        for _ in 0 ..< count {
            let randomSectionIndex = Int.random() % sections.count
            var randomSection = sections[randomSectionIndex]
            
            if randomSection.elements.count == 0 { continue }
            
            let randomCellDataIndex = Int.random() % randomSection.elements.count 
            let oldCellData = randomSection.elements[randomCellDataIndex]
            
            let newCellData = CellData(
                differenceIdentifier: oldCellData.differenceIdentifier,
                title: oldCellData.title + " *",
                subtitle: oldCellData.subtitle
            )
            
            randomSection.elements[randomCellDataIndex] = newCellData
            sections[randomSectionIndex] = randomSection
            
            reallyUpdatedCellDataCount += 1
        }
    }

    private func insertSections(into sections: inout Sections, count sectionInserts: Int) {
        let initialSectionsCount = sections.count
        
        let sectionDataList = generateSectionData(count: sectionInserts)
        
        for sectionData in sectionDataList {
            let section = ArraySection(
                model: sectionData,
                elements: [CellData]()
            )
            
            sections.append(section)
        }
        
        assert(sections.count == initialSectionsCount + sectionInserts)
    }
    
    private func deleteSections(from sections: inout Sections, count: inout Int, deletedCellDataCount: inout Int) {
        let initialSectionsCount = sections.count
        var reallyDeletedSectionsCount = 0
        var reallyDeletedElementsCount = 0
        defer {
            count = reallyDeletedSectionsCount
            deletedCellDataCount = reallyDeletedElementsCount
            assert(sections.count == initialSectionsCount - reallyDeletedSectionsCount)
        }
        
        for _ in 0 ..< count where sections.count != 0 {
            let randomSectionIndex = Int.random() % sections.count
            let randomSection = sections.remove(at: randomSectionIndex)
            
            reallyDeletedSectionsCount += 1
            reallyDeletedElementsCount += randomSection.elements.count
        }
    }
    
    private func moveSections(in sections: inout Sections, count: inout Int) {
        let initialSectinsCount = sections.count
        var reallyMovedSectionsCount = 0
        defer {
            count = reallyMovedSectionsCount
            assert(sections.count == initialSectinsCount)
        }
        
        for _ in 0 ..< count where sections.count > 1 {
            let randomFromIndex = Int.random() % sections.count
            
            let section = sections.remove(at: randomFromIndex)
            
            if sections.isEmpty {
                sections.append(section)
            } else {
                let randomToIndex = Int.random() % sections.count
                sections.insert(section, at: randomToIndex)
            }
            reallyMovedSectionsCount += 1
        }
    }
    
    private func updateSections(in sections: inout Sections, count: inout Int) {
        let initialSectionsCount = sections.count
        var reallyUpdatedSectionsCount = 0
        defer {
            count = reallyUpdatedSectionsCount
            assert(sections.count == initialSectionsCount)
        }
        
        for _ in 0 ..< count where sections.count != 0 {
            let randomFromIndex = Int.random() % sections.count
            
            var section = sections[randomFromIndex]
            
            let oldSectionData = section.model
            
            let newSectionData = SectionData(
                differenceIdentifier: oldSectionData.differenceIdentifier,
                title: oldSectionData.title + " *"
            )
            
            section.model = newSectionData
            sections[randomFromIndex] = section
            reallyUpdatedSectionsCount += 1
        }
    }
}

extension Int {
    static func random() -> Int {
        let random = arc4random()
        
        if let intValue = Int(exactly: random) {
            return intValue
        } else {
            // Int.max < UInt32.max (32-bit systems)
            let maxUintRepresentableByInt = UInt32(Int32.max)
            if random <= maxUintRepresentableByInt {
                return Int(random)
            } else {
                return Int(random % maxUintRepresentableByInt)
            }
        }
    }
}

extension Range where Bound == Int {
    var middle: Int {
        return (lowerBound + upperBound) / 2
    }
    
    var oneThird: Int {
        return lowerBound + (upperBound - lowerBound) / 3
    }
    
    var oneFourth: Int {
        return lowerBound + (upperBound - lowerBound) / 4
    }
}
