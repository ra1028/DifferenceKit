#if canImport(UIKit)
import DifferenceKit
import XCTest

final class CollectionMutator {
    func generateCollection(
        sectionsCount: Int,
        cellsCount: Int)
        -> CollectionMutatation
    {
        let sectionDataList = generateSectionData(count: sectionsCount)
        let cellDataList = generateCellData(count: cellsCount)
        let collection = generateCollectionFrom(sectionDataList, cellDataList)
        
        return CollectionMutatation(
            sectionDeletes: 0,
            sectionInserts: collection.sectionsCount,
            sectionMoves: 0,
            sectionUpdates: 0,
            cellDeletes: 0,
            cellInserts: collection.totalCellDataCount,
            cellMoves: 0,
            cellUpdates: 0,
            from: [],
            to: collection
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
    
    private func generateCollectionFrom(
        _ sectionDataList: [SectionData],
        _ cellDataList: [CellData])
        -> Collection
    {
        var collection = Collection()
        var cellDataList = cellDataList
        
        for (index, sectionData) in sectionDataList.enumerated() where cellDataList.count != 0 {
            let cellsInSection = (index == sectionDataList.endIndex)
                ? Int.random() % cellDataList.count
                : cellDataList.count
            
            let sectionCellDataList = Array(cellDataList.prefix(cellsInSection))
            cellDataList = Array(cellDataList.dropFirst(cellsInSection))
            
            let section = ArraySection(model: sectionData, elements: sectionCellDataList)
            collection.append(section)
        }
        
        return collection
    }
    
    func performRandomActionsOnCollection(
        _ oldCollection: Collection,
        recommendedSectionsCountRange: Range<Int>,
        recommendedTotalCellsCountRange: Range<Int>)
        -> CollectionMutatation
    {
        var newCollection = oldCollection
        
        let willDeleteSections = oldCollection.sectionsCount > recommendedSectionsCountRange.lowerBound
        let willInsertSections = oldCollection.sectionsCount < recommendedSectionsCountRange.upperBound
        
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
            deleteSections(from: &newCollection, count: &sectionDeletes, cellDeletesCount: &cellDeletesDuringSectionDeletes)
        }
        
        if willInsertSections {
            sectionInserts = Int.random() % recommendedSectionsCountRange.middle
            insertSections(into: &newCollection, count: sectionInserts)
        }
        
        sectionMoves = Int.random() % recommendedSectionsCountRange.oneThird
        moveSections(in: &newCollection, count: &sectionMoves)
        
        sectionUpdates = Int.random() % recommendedSectionsCountRange.oneThird
        updateSections(in: &newCollection, count: &sectionUpdates)
        
        // Decide wether or not to insert / delete cells depending on the updated section's capacities
        // (use `newCollection` instead of `oldCollection)
        let willDeleteCells = newCollection.totalCellDataCount > recommendedTotalCellsCountRange.lowerBound
        let willInsertCells = newCollection.totalCellDataCount < recommendedTotalCellsCountRange.upperBound
        
        if willDeleteCells {
            cellDeletes = Int.random() % recommendedTotalCellsCountRange.oneThird
            deleteCells(from: &newCollection, count: &cellDeletes)
        }
        
        if willInsertCells {
            cellInserts = Int.random() % recommendedTotalCellsCountRange.oneThird
            insertCells(into: &newCollection, count: &cellInserts)
        }
        
        cellMoves = Int.random() % recommendedTotalCellsCountRange.oneFourth
        moveCells(in: &newCollection, count: &cellMoves)
        
        cellUpdates = Int.random() % recommendedTotalCellsCountRange.oneFourth
        updateCells(in: &newCollection, count: &cellUpdates)
        
        // Sanity checks
        XCTAssert(oldCollection.sectionsCount - sectionDeletes + sectionInserts == newCollection.sectionsCount)
        XCTAssert(oldCollection.totalCellDataCount - cellDeletes - cellDeletesDuringSectionDeletes + cellInserts == newCollection.totalCellDataCount)
        
        return CollectionMutatation(
            sectionDeletes: sectionDeletes,
            sectionInserts: sectionInserts,
            sectionMoves: sectionMoves,
            sectionUpdates: sectionUpdates,
            cellDeletes: cellDeletes + cellDeletesDuringSectionDeletes,
            cellInserts: cellInserts,
            cellMoves: cellMoves,
            cellUpdates: cellUpdates,
            from: oldCollection,
            to: newCollection
        )
    }
    
    func performNoActionsOnCollection(_ collection: Collection)
        -> CollectionMutatation
    {
        return CollectionMutatation(
            sectionDeletes: 0,
            sectionInserts: 0,
            sectionMoves: 0,
            sectionUpdates: 0,
            cellDeletes: 0,
            cellInserts: 0,
            cellMoves: 0,
            cellUpdates: 0,
            from: collection,
            to: collection
        )
    }
    
    private func insertCells(into collection: inout Collection, count: inout Int) {
        let initialCellDataCount = collection.totalCellDataCount
        var reallyInsertedCellDataCount = 0
        defer {
            count = reallyInsertedCellDataCount
            XCTAssert(collection.totalCellDataCount == initialCellDataCount + reallyInsertedCellDataCount)
        }
        
        guard collection.sectionsCount != 0 else { return }
        
        for _ in 0 ..< count {
            let cellData = CellData(
                differenceIdentifier: UUID(),
                title: UUID().uuidString,
                subtitle: UUID().uuidString
            )
            
            let randomSectionIndex = Int.random() % collection.sectionsCount
            var randomSection = collection[randomSectionIndex]
            
            if randomSection.elements.isEmpty {
                randomSection.elements.append(cellData)
            } else {
                let randomCellDataIndex = Int.random() % randomSection.elements.count
                randomSection.elements.insert(cellData, at: randomCellDataIndex)
            }
            
            collection[randomSectionIndex] = randomSection
            
            reallyInsertedCellDataCount += 1
        }
    }
    
    private func deleteCells(from collection: inout Collection, count: inout Int) {
        let initialCellDataCount = collection.totalCellDataCount
        var reallyDeletedCellDataCount = 0
        defer {
            count = reallyDeletedCellDataCount
            XCTAssert(collection.totalCellDataCount == initialCellDataCount - reallyDeletedCellDataCount)
        }
        
        for _ in 0 ..< count {
            guard collection.totalCellDataCount != 0 else { return }
            
            var sectionIndexes = Array((0..<collection.sectionsCount))
            
            while !sectionIndexes.isEmpty {
                let randomSectionIndex = Int.random() % sectionIndexes.count
                sectionIndexes.remove(at: randomSectionIndex)
                
                var randomSection = collection[randomSectionIndex]
                if randomSection.elements.count > 0 {
                    let randomCellDataIndex = Int.random() % randomSection.elements.count
                    randomSection.elements.remove(at: randomCellDataIndex)
                    collection[randomSectionIndex] = randomSection
                    reallyDeletedCellDataCount += 1
                }
            }
        }
    }
    
    private func moveCells(in collection: inout Collection, count: inout Int) {
        let initialCellDataCount = collection.totalCellDataCount
        var reallyMovedCellDataCount = 0
        defer {
            count = reallyMovedCellDataCount
            XCTAssert(collection.totalCellDataCount == initialCellDataCount)
        }
        
        guard collection.totalCellDataCount != 0 else { return }
        
        for _ in 0 ..< count {
            let randomFromSectionIndex = Int.random() % collection.sectionsCount
            let randomToSectionIndex = Int.random() % collection.sectionsCount
            
            var randomFromSection = collection[randomFromSectionIndex]
            var randomToSection = collection[randomToSectionIndex]
            
            if randomFromSection.elements.count == 0 || randomToSection.elements.count == 0 { continue }
            
            let randomFromCellDataIndex = Int.random() % randomFromSection.elements.count
            let movedCellData = randomFromSection.elements.remove(at: randomFromCellDataIndex)
            if randomFromSectionIndex == randomToSectionIndex {
                randomToSection.elements.remove(at: randomFromCellDataIndex)
            }
            collection[randomFromSectionIndex] = randomFromSection
            
            if randomToSection.elements.isEmpty {
                randomToSection.elements.append(movedCellData)
            } else {
                let randomToCellDataIndex = Int.random() % randomToSection.elements.count
                randomToSection.elements.insert(movedCellData, at: randomToCellDataIndex)
            }
            collection[randomToSectionIndex] = randomToSection
            
            reallyMovedCellDataCount += 1
        }
    }
    
    private func updateCells(in collection: inout Collection, count: inout Int) {
        let initialCellDataCount = collection.totalCellDataCount
        var reallyUpdatedCellDataCount = 0
        defer {
            count = reallyUpdatedCellDataCount
            XCTAssert(collection.totalCellDataCount == initialCellDataCount)
        }
        
        guard collection.totalCellDataCount != 0 else { return }
        
        for _ in 0 ..< count {
            let randomSectionIndex = Int.random() % collection.sectionsCount
            var randomSection = collection[randomSectionIndex]
            
            if randomSection.elements.count == 0 { continue }
            
            let randomCellDataIndex = Int.random() % randomSection.elements.count 
            let oldCellData = randomSection.elements[randomCellDataIndex]
            
            let newCellData = CellData(
                differenceIdentifier: oldCellData.differenceIdentifier,
                title: oldCellData.title + " *",
                subtitle: oldCellData.subtitle
            )
            
            randomSection.elements[randomCellDataIndex] = newCellData
            collection[randomSectionIndex] = randomSection
            
            reallyUpdatedCellDataCount += 1
        }
    }

    private func insertSections(into collection: inout Collection, count sectionInserts: Int) {
        let initialSectionsCount = collection.sectionsCount
        
        let sectionDataList = generateSectionData(count: sectionInserts)
        
        for sectionData in sectionDataList {
            let section = ArraySection(
                model: sectionData,
                elements: [CellData]()
            )
            
            collection.append(section)
        }
        
        XCTAssert(collection.sectionsCount == initialSectionsCount + sectionInserts)
    }
    
    private func deleteSections(from collection: inout Collection, count: inout Int, cellDeletesCount: inout Int) {
        let initialSectionsCount = collection.sectionsCount
        var reallyDeletedSectionsCount = 0
        var reallyDeletedCellDataCount = 0
        defer {
            count = reallyDeletedSectionsCount
            cellDeletesCount = reallyDeletedCellDataCount
            XCTAssert(collection.sectionsCount == initialSectionsCount - reallyDeletedSectionsCount)
        }
        
        for _ in 0 ..< count where collection.sectionsCount != 0 {
            let randomSectionIndex = Int.random() % collection.sectionsCount
            let randomSection = collection.remove(at: randomSectionIndex)
            
            reallyDeletedSectionsCount += 1
            reallyDeletedCellDataCount += randomSection.elements.count
        }
    }
    
    private func moveSections(in collection: inout Collection, count: inout Int) {
        let initialSectionsCount = collection.sectionsCount
        var reallyMovedSectionsCount = 0
        defer {
            count = reallyMovedSectionsCount
            XCTAssert(collection.sectionsCount == initialSectionsCount)
        }
        
        for _ in 0 ..< count where collection.sectionsCount > 1 {
            let randomFromSectionIndex = Int.random() % collection.sectionsCount
            
            let section = collection.remove(at: randomFromSectionIndex)
            
            if collection.isEmpty {
                collection.append(section)
            } else {
                let randomToSectionIndex = Int.random() % collection.sectionsCount
                collection.insert(section, at: randomToSectionIndex)
            }
            
            reallyMovedSectionsCount += 1
        }
    }
    
    private func updateSections(in collection: inout Collection, count: inout Int) {
        let initialSectionsCount = collection.sectionsCount
        var reallyUpdatedSectionsCount = 0
        defer {
            count = reallyUpdatedSectionsCount
            XCTAssert(collection.sectionsCount == initialSectionsCount)
        }
        
        for _ in 0 ..< count where collection.sectionsCount != 0 {
            let randomSectionIndex = Int.random() % collection.sectionsCount
            
            var section = collection[randomSectionIndex]
            
            let oldSectionData = section.model
            
            let newSectionData = SectionData(
                differenceIdentifier: oldSectionData.differenceIdentifier,
                title: oldSectionData.title + " *"
            )
            
            section.model = newSectionData
            collection[randomSectionIndex] = section
            
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
#endif
