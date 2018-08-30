#if canImport(UIKit)
struct CollectionMutatation {
    let sectionDeletes: Int
    let sectionInserts: Int
    let sectionMoves: Int
    let sectionUpdates: Int
    
    let cellDeletes: Int
    let cellInserts: Int
    let cellMoves: Int
    let cellUpdates: Int
    
    let from: Collection
    let to: Collection
}
#endif
