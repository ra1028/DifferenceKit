final class CellDataGenerator {
    func generateCellData(count: Int) -> CellDataGeneratorResult {
        var cellDataList = [CellData]()
        
        insertCellData(
            into: &cellDataList,
            count: count
        )
        
        return CellDataGeneratorResult(
            deletes: 0,
            inserts: count,
            moves: 0, updates: 0,
            from: [],
            to: cellDataList
        ) 
    }
    
    func performRandomActionsOnCellData(
        _ cellDataList: [CellData],
        minimumCountAfterActions: Int,
        maximumCountAfterActions: Int)
        -> CellDataGeneratorResult
    {
        var newCellDataList = cellDataList
        
        var inserts = Int.random() % maximumCountAfterActions / 2
        insertCellData(into: &newCellDataList, count: inserts)
        
        var deletes = Int.random() % maximumCountAfterActions / 2
        deleteCellData(from: &newCellDataList, count: &deletes)
        
        var moves = Int.random() % maximumCountAfterActions / 3
        moveCellData(in: &newCellDataList, count: &moves)
        
        var updates = Int.random() % maximumCountAfterActions / 3
        updateCellData(in: &newCellDataList, count: &updates)
        
        if newCellDataList.count < minimumCountAfterActions {
            inserts += minimumCountAfterActions
            insertCellData(into: &newCellDataList, count: minimumCountAfterActions)
        }
        
        if newCellDataList.count > maximumCountAfterActions {
            var extraItems = newCellDataList.count - maximumCountAfterActions
            deleteCellData(from: &newCellDataList, count: &extraItems)
            deletes += extraItems
        }
        
        return CellDataGeneratorResult(
            deletes: deletes,
            inserts: inserts,
            moves: moves,
            updates: updates,
            from: cellDataList,
            to: newCellDataList
        )
    }
    
    func performNoActionsOnCellData(_ cellDataList: [CellData])
        -> CellDataGeneratorResult
    {
        return CellDataGeneratorResult(
            deletes: 0,
            inserts: 0,
            moves: 0,
            updates: 0,
            from: cellDataList,
            to: cellDataList
        )
    }
    
    // MARK: - Private
    private func insertCellData(into cellDataList: inout [CellData], count: Int) {
        for _ in 0 ..< count {
            let cellData = CellData(
                differenceIdentifier: UUID(),
                title: UUID().uuidString,
                subtitle: UUID().uuidString
            )
            
            if cellDataList.isEmpty {
                cellDataList.append(cellData)
            } else {
                let randomIndex = Int.random() % cellDataList.count
                cellDataList.insert(cellData, at: randomIndex)
            }
        }
    }
    
    private func deleteCellData(from cellDataList: inout [CellData], count: inout Int) {
        for i in 0 ..< count where !cellDataList.isEmpty {
            let randomIndex = Int.random() % cellDataList.count
            cellDataList.remove(at: randomIndex)
            count = i + 1
        }
    }
    
    private func moveCellData(in cellDataList: inout [CellData], count: inout Int) {
        for i in 0 ..< count where !cellDataList.isEmpty {
            let randomFromIndex = Int.random() % cellDataList.count
            let cellData = cellDataList.remove(at: randomFromIndex)
            
            if cellDataList.isEmpty {
                cellDataList.append(cellData)
            } else {
                let randomToIndex = Int.random() % cellDataList.count
                cellDataList.insert(cellData, at: randomToIndex)
            }
            count = i + 1
        }
    }
    
    private func updateCellData(in cellDataList: inout [CellData], count: inout Int) {
        for i in 0 ..< count where !cellDataList.isEmpty {
            let randomIndex = Int.random() % cellDataList.count
            
            let oldCellData = cellDataList[randomIndex]
            
            let newCellData = CellData(
                differenceIdentifier: oldCellData.differenceIdentifier,
                title: oldCellData.title + " *",
                subtitle: oldCellData.subtitle
            )
            
            cellDataList[randomIndex] = newCellData
            count = i + 1
        }
    }
}

private extension Int {
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
