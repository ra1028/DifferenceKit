/*:
 ## Welcome to `DifferenceKit` Playground
 ----
 > 1. Open DifferenceKit.xcworkspace.
 > 2. Build the DifferenceKit.
 > 3. Open DifferenceKit playground in project navigator.
 > 4. Show the live view in assistant editor.
 */
import DifferenceKit
import PlaygroundSupport
import UIKit

let viewController = TableViewController()
let navigationController = UINavigationController(rootViewController: viewController)
navigationController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = navigationController.view

let source = [
    ArraySection(model: "Section 1", elements: ["A", "B", "C"]),
    ArraySection(model: "Section 2", elements: ["D", "E", "F"]),
    ArraySection(model: "Section 3", elements: ["G", "H", "I"]),
    ArraySection(model: "Section 4", elements: ["J", "K", "L"])
]

let target = [
    ArraySection(model: "Section 5", elements: ["M", "N", "O"]),
    ArraySection(model: "Section 1", elements: ["A", "C"]),
    ArraySection(model: "Section 4", elements: ["J", "I", "K", "L"]),
    ArraySection(model: "Section 3", elements: ["G", "H", "Z"]),
    ArraySection(model: "Section 6", elements: ["P", "Q", "R"])
]

viewController.dataInput = source

var isSourceShown = true
viewController.refreshAction = {
    viewController.dataInput = isSourceShown ? target : source
    isSourceShown = !isSourceShown
}
