<img src="https://raw.githubusercontent.com/ra1028/DifferenceKit/master/assets/sample.gif" height="310" align="right">

<p align="center">
<img src="https://raw.githubusercontent.com/ra1028/DifferenceKit/master/assets/logo.png" width="500">
</p>

<H4 align="center">
A fast and flexible O(n) difference algorithm framework for Swift collection.</br>
The algorithm is optimized based on the Paul Heckel's algorithm.
</H4>

<p align="center">
<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"/></a>
<a href="https://github.com/ra1028/DifferenceKit/releases/latest"><img alt="Release" src="https://img.shields.io/github/release/ra1028/DifferenceKit.svg"/></a>
<a href="https://cocoapods.org/pods/DifferenceKit"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/DifferenceKit.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg"/></a>
<a href="https://swift.org/package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/SwiftPM-compatible-yellowgreen.svg"/></a>
</br>
<a href="https://dev.azure.
com/ra1028/GitHub/_build/latest?definitionId=1&branchName=master"><img alt="Build Status" src="https://dev.azure.com/ra1028/GitHub/_apis/build/status/ra1028.DifferenceKit?branchName=master"/></a>
<a href="https://developer.apple.com/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-green.svg"/></a>
<a href="https://github.com/ra1028/DifferenceKit/blob/master/LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/License-Apache%202.0-black.svg"/></a>
</p>

<br>

<p align="center">
Made with ❤️ by <a href="https://github.com/ra1028">Ryo Aoyama</a> and <a href="https://github.com/ra1028/DifferenceKit/graphs/contributors">Contributors</a>
<br clear="all">
</p>

---

## Features

💡 Fastest **O(n)** diffing algorithm optimized for Swift collection

💡 Calculate diffs for batch updates of list UI in `UIKit`, `AppKit` and [Texture](https://github.com/TextureGroup/Texture)

💡 Supports both linear and sectioned collection even if contains duplicates

💡 Supports **all kind of diffs** for animated UI batch updates

---

## Algorithm

This is a diffing algorithm developed for [Carbon](https://github.com/ra1028/Carbon), works stand alone.  
The algorithm optimized based on the Paul Heckel's algorithm.  
See also his paper ["A technique for isolating differences between files"](https://dl.acm.org/citation.cfm?id=359467) released in 1978.  
It allows all kind of diffs to be calculated in linear time **O(n)**.  
[RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) and [IGListKit](https://github.com/Instagram/IGListKit) are also implemented based on his algorithm.  

However, in `performBatchUpdates` of `UITableView`, `UICollectionView`, etc, there are combinations of diffs that cause crash when applied simultaneously.  
To solve this problem, `DifferenceKit` takes an approach of split the set of diffs at the minimal stages that can be perform batch updates with no crashes.

Implementation is [here](https://github.com/ra1028/DifferenceKit/blob/master/Sources/Algorithm.swift).

---

## Getting Started

- [API Documentation](https://ra1028.github.io/DifferenceKit)
- [Example Apps](https://github.com/ra1028/DifferenceKit/blob/master/Examples)
- [Benchmark](https://github.com/ra1028/DifferenceKit/blob/master/Benchmark)
- [Playground](https://github.com/ra1028/DifferenceKit/blob/master/DifferenceKit.playground/Contents.swift)

## Basic Usage

The type of the element that to take diffs must be conform to the `Differentiable` protocol.  
The `differenceIdentifier`'s type is generic associated type:
```swift
struct User: Differentiable {
    let id: Int
    let name: String

    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: User) -> Bool {
        return name == source.name
    }
}
```

In the case of definition above, `id` uniquely identifies the element and get to know the user updated by comparing equality of `name` of the elements in source and target.

There are default implementations of `Differentiable` for the types that conforming to `Equatable` or `Hashable`：
```swift
// If `Self` conforming to `Hashable`.
var differenceIdentifier: Self {
    return self
}

// If `Self` conforming to `Equatable`.
func isContentEqual(to source: Self) -> Bool {
    return self == source
}
```
Therefore, you can simply:
```swift
extension String: Differentiable {}
```

Calculate the diffs by creating `StagedChangeset` from two collections of elements conforming to `Differentiable`:
```swift
let source = [
    User(id: 0, name: "Vincent"),
    User(id: 1, name: "Jules")
]
let target = [
    User(id: 1, name: "Jules"),
    User(id: 0, name: "Vincent"),
    User(id: 2, name: "Butch")
]

let changeset = StagedChangeset(source: source, target: target)
```

If you want to include multiple types conforming to `Differentiable` in the collection, use `AnyDifferentiable`:
```swift
let source = [
    AnyDifferentiable("A"),
    AnyDifferentiable(User(id: 0, name: "Vincent"))
]
```

In the case of sectioned collection, the section itself must have a unique identifier and be able to compare whether there is an update.  
So each section must conforming to `DifferentiableSection` protocol, but in most cases you can use `ArraySection` that general type conforming to it.  
`ArraySection` requires a model conforming to `Differentiable` for diffing from other sections:
```swift
enum Model: Differentiable {
    case a, b, c
}

let source: [ArraySection<Model, String>] = [
    ArraySection(model: .a, elements: ["A", "B"]),
    ArraySection(model: .b, elements: ["C"])
]
let target: [ArraySection<Model, String>] = [
    ArraySection(model: .c, elements: ["D", "E"]),
    ArraySection(model: .a, elements: ["A"]),
    ArraySection(model: .b, elements: ["B", "C"])
]

let changeset = StagedChangeset(source: source, target: target)
```

You can perform diffing batch updates of `UITableView` and `UICollectionView` using the created `StagedChangeset`.  

⚠️ **Don't forget** to **synchronously** update the data referenced by the data-source, with the data passed in the `setData` closure. The diffs are applied in stages, and failing to do so is bound to create a crash:

```swift
tableView.reload(using: changeset, with: .fade) { data in
    dataSource.data = data
}
```

Batch updates using too large amount of diffs may adversely affect to performance.  
Returning `true` with `interrupt` closure then falls back to `reloadData`:
```swift
collectionView.reload(using: changeset, interrupt: { $0.changeCount > 100 }) { data in
    dataSource.data = data
}
```

<H3 align="center">
<a href="https://ra1028.github.io/DifferenceKit">[See More Usage]</a>
</H3>

---

## Comparison with Other Frameworks

Made a fair comparison as much as possible in performance and features with other **popular** and **awesome** frameworks.  
This does **NOT** determine superiority or inferiority of the frameworks.  
I know that each framework has different benefits.  
The frameworks and its version that compared is below.  

- [DifferenceKit](https://github.com/ra1028/DifferenceKit) - master
- [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) ([Differentiator](https://github.com/RxSwiftCommunity/RxDataSources/tree/master/Sources/Differentiator)) - 4.0.1
- [FlexibleDiff](https://github.com/RACCommunity/FlexibleDiff) - 0.0.8
- [IGListKit](https://github.com/Instagram/IGListKit) - 3.4.0
- [DeepDiff](https://github.com/onmyway133/DeepDiff) - 2.0.1
- [Differ](https://github.com/tonyarnold/Differ) ([Diff.swift](https://github.com/wokalski/Diff.swift)) - 1.4.1
- [Dwifft](https://github.com/jflinter/Dwifft) - 0.9

### Performance Comparison

Benchmark project is [here](https://github.com/ra1028/DifferenceKit/blob/master/Benchmark).  
Performance was mesured by code compiled using `Xcode10.2` and `Swift 5.0` with `-O -whole-module-optimization` and run on `iPhoneXs simulator`.  
Use `Foundation.UUID` as an element of collections.  

#### - From 5,000 elements to 1,000 deleted, 1,000 inserted and 200 shuffled

|             |Time(sec)    |
|:------------|------------:|
|DifferenceKit|`0.0021`     |
|RxDataSources|`0.0067`     |
|IGListKit    |`0.0490`     |
|FlexibleDiff |`0.0117`     |
|DeepDiff     |`0.0263`     |
|Differ       |`1.2661`     |
|Dwifft       |`0.4552`     |

#### - From 100,000 elements to 10,000 deleted, 10,000 inserted and 2,000 shuffled

|             |Time(sec)    |
|:------------|------------:|
|DifferenceKit|`0.0364`     |
|RxDataSources|`0.1167`     |
|IGListKit    |`1.0130`     |
|FlexibleDiff |`0.2104`     |
|DeepDiff     |`0.4180`     |
|Differ       |`136.8958`   |
|Dwifft       |`211.4457`   |

### Features Comparison

#### - Supported Collection

|             |Linear|Sectioned|Duplicate element/section|
|:------------|:----:|:-------:|:-----------------------:|
|DifferenceKit|✅    |✅       |✅                      |
|RxDataSources|❌    |✅       |❌                      |
|FlexibleDiff |✅    |✅       |✅                      |
|IGListKit    |✅    |❌       |✅                      |
|DeepDiff     |✅    |❌       |✅                      |
|Differ       |✅    |✅       |✅                      |
|Dwifft       |✅    |✅       |✅                      |

\* **Linear** means 1-dimensional collection  
\* **Sectioned** means 2-dimensional collection  

#### - Supported Element Diff

|             |Delete|Insert|Move|Reload|Move across sections|
|:------------|:----:|:----:|:--:|:----:|:------------------:|
|DifferenceKit|✅    |✅    |✅ |✅    |✅                  |
|RxDataSources|✅    |✅    |✅ |✅    |✅                  |
|FlexibleDiff |✅    |✅    |✅ |✅    |❌                  |
|IGListKit    |✅    |✅    |✅ |✅    |❌                  |
|DeepDiff     |✅    |✅    |✅ |✅    |❌                  |
|Differ       |✅    |✅    |✅ |❌    |❌                  |
|Dwifft       |✅    |✅    |❌ |❌    |❌                  |

#### - Supported Section Diff

|             |Delete|Insert|Move|Reload|
|:------------|:----:|:----:|:--:|:----:|
|DifferenceKit|✅    |✅    |✅ |✅    |
|RxDataSources|✅    |✅    |✅ |❌    |
|FlexibleDiff |✅    |✅    |✅ |✅    |
|IGListKit    |❌    |❌    |❌ |❌    |
|DeepDiff     |❌    |❌    |❌ |❌    |
|Differ       |✅    |✅    |✅ |❌    |
|Dwifft       |✅    |✅    |❌ |❌    |

---

## Requirements

- Swift 4.2+
- iOS 9.0+
- tvOS 9.0+
- OS X 10.9+
- watchOS 2.0+ (only algorithm)

---

## Installation

### [CocoaPods](https://cocoapods.org/)

To use only algorithm without extensions for UI, add the following to your `Podfile`:
```ruby
pod 'DifferenceKit/Core'
```

#### iOS / tvOS

To use DifferenceKit with UIKit extension, add the following to your `Podfile`:
```ruby
pod 'DifferenceKit'
```
or
```ruby
pod 'DifferenceKit/UIKitExtension'
```

#### macOS

To use DifferenceKit with AppKit extension, add the following to your `Podfile`:
```ruby
pod 'DifferenceKit/AppKitExtension'
```

#### watchOS

There is no UI extension for watchOS.  
To use only algorithm without extensions for UI, add the following to your `Podfile`:
```ruby
pod 'DifferenceKit/Core'
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the following to your `Cartfile`:
```ruby
github "ra1028/DifferenceKit"
```

### [Swift Package Manager](https://swift.org/package-manager/)

The SwiftPM version does not include the extensions for UI.  
Add the following to the dependencies of your `Package.swift`:
```swift
.package(url: "https://github.com/ra1028/DifferenceKit.git", from: "version")
```

---

## Contribution

Pull requests, bug reports and feature requests are welcome 🚀  
Please see the [CONTRIBUTING](https://github.com/ra1028/DifferenceKit/blob/master/CONTRIBUTING.md) file for learn how to contribute to DifferenceKit. 
 
---

## Credit

#### Bibliography
DifferenceKit was developed with reference to the following excellent materials and framework.  

- [A technique for isolating differences between files](https://dl.acm.org/citation.cfm?id=359467) (by [Paul Heckel](https://dl.acm.org/author_page.cfm?id=81100051772))
- [DifferenceAlgorithmComparison](https://github.com/horita-yuya/DifferenceAlgorithmComparison) (by [@horita-yuya](https://github.com/horita-yuya))
- [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) (by [@kzaher](https://github.com/kzaher), [RxSwift Community](https://github.com/RxSwiftCommunity))

#### OSS using DifferenceKit
The list of the awesome OSS which uses this library. They also help to understanding how to use DifferenceKit.  

- [Carbon](https://github.com/ra1028/Carbon) (by [@ra1028](https://github.com/ra1028))
- [Rocket.Chat.iOS](https://github.com/RocketChat/Rocket.Chat.iOS) (by [RocketChat](https://github.com/RocketChat))
- [wire-ios](https://github.com/wireapp/wire-ios) (by [Wire Swiss GmbH](https://github.com/wireapp))
- [ReactiveLists](https://github.com/plangrid/ReactiveLists) (by [PlanGrid](https://github.com/plangrid))
- [ReduxMovieDB](https://github.com/cardoso/ReduxMovieDB) (by [@cardoso](https://github.com/cardoso))
- [TetrisDiffingCompetition](https://github.com/skagedal/TetrisDiffingCompetition) (by [@skagedal](https://github.com/skagedal))

#### Other diffing libraries
I respect and ️❤️ all libraries involved in diffing.  

- [IGListKit](https://github.com/Instagram/IGListKit) (by [Instagram](https://github.com/Instagram))
- [FlexibleDiff](https://github.com/RACCommunity/FlexibleDiff) (by [@andersio](https://github.com/andersio), [RACCommunity](https://github.com/RACCommunity))
- [DeepDiff](https://github.com/onmyway133/DeepDiff) (by [@onmyway133](https://github.com/onmyway133))
- [Differ](https://github.com/tonyarnold/Differ) (by [@tonyarnold](https://github.com/tonyarnold))
- [Dwifft](https://github.com/jflinter/Dwifft) (by [@jflinter](https://github.com/jflinter))
- [Changeset](https://github.com/osteslag/Changeset) (by [@osteslag](https://github.com/osteslag))

---

## License
DifferenceKit is released under the [Apache 2.0 License](https://github.com/ra1028/DifferenceKit/blob/master/LICENSE).
