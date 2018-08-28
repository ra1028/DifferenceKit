struct CellDataGeneratorResult {
    let deletes: Int
    let inserts: Int
    let moves: Int
    let updates: Int
    let from: [CellData]
    let to: [CellData]
}
