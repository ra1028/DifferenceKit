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
    Section(model: "Section 1", elements: ["A", "B", "C"]),
    Section(model: "Section 2", elements: ["D", "E", "F"]),
    Section(model: "Section 3", elements: ["G", "H", "I"]),
    Section(model: "Section 4", elements: ["J", "K", "L"])
]

let target = [
    Section(model: "Section 5", elements: ["M", "N", "O"]),
    Section(model: "Section 1", elements: ["A", "C"]),
    Section(model: "Section 4", elements: ["J", "I", "K", "L"]),
    Section(model: "Section 3", elements: ["G", "H", "Z"]),
    Section(model: "Section 6", elements: ["P", "Q", "R"]),
]

viewController.dataInput = source

var isSourceShown = true
viewController.refreshAction = {
    viewController.dataInput = isSourceShown ? target : source
    isSourceShown = !isSourceShown
}
