import UIKit
import DifferenceKit

extension String: Differentiable {}

// FIXME: This extension is not required after Swift 4.2
// https://github.com/apple/swift/blob/master/stdlib/public/core/Integers.swift.gyb
extension Int {
    static func random(in range: Range<Int>) -> Int {
        let delta = range.upperBound - range.lowerBound
        let offset = Int(arc4random_uniform(UInt32(delta)))
        return range.lowerBound + offset
    }
}

// FIXME: This extension is not required after Swift 4.2
// https://github.com/apple/swift/blob/master/stdlib/public/core/CollectionAlgorithms.swift
extension MutableCollection {
    mutating func shuffle() {
        let count = self.count
        guard count > 1 else { return }

        var amount = count
        var currentIndex = startIndex

        while amount > 1 {
            let random = Int(arc4random_uniform(UInt32(amount)))
            amount -= 1
            swapAt(currentIndex, index(currentIndex, offsetBy: numericCast(random)))
            formIndex(after: &currentIndex)
        }
    }
}

// FIXME: This extension is not required after Swift 4.2
// https://github.com/apple/swift/blob/master/stdlib/public/core/Bool.swift
extension Bool {
    mutating func toggle() {
        self = !self
    }
}
