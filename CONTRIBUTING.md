# 💻 Contributing to DifferenceKit

First of all, thanks for your interest in DifferenceKit.  

There are several ways to contribute to this project. We welcome contributions in all ways.  
We have made some contribution guidelines to smoothly incorporate your opinions and code into this project.  

## 📝 Open Issue

When you found a bug or having a feature request, search for the issue from the [existing](https://github.com/ra1028/DifferenceKit/issues) and feel free to open the issue after making sure it isn't already reported.  

In order to we understand your issue accurately, please include as much information as possible in the issue template.  
The screenshot are also big clue to understand the issue.  

If you know exactly how to fix the bug you report or implement the feature you propose, please pull request instead of an issue.  

## 🚀 Pull Request

We are waiting for a pull request to make this project more better with us.  
If you want to add a new feature, let's discuss about it first on issue.  

```bash
$ git clone https://github.com/ra1028/DifferenceKit.git
$ cd DifferenceKit/
$ open DifferenceKit.xcworkspace
```

### Lint

Please introduce [SwiftLint](https://github.com/realm/SwiftLint) into your environment before start writing the code.  
Xcode automatically runs lint in the build phase.  

The code written according to lint should match our coding style, but for particular cases where style is unknown, refer to the existing code base.  

### Test

The test will tells us the validity of your code.  
All codes entering the master must pass the all tests.  
If you change the code or add new features, you should add tests.  

### Documentation

Please write the document using [Xcode markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/) to the code you added.  
Documentation template is inserted automatically by using Xcode shortcut **⌥⌘/**.  
Our document style is slightly different from the template. The example is below.  
```swift
/// The example class for documentation.
final class Foo {
    /// A property value.
    let prop: Int

    /// Create a new foo with a param.
    ///
    /// - Parameters:
    ///   -  param: An Int value for prop.
    init(param: Int) {
        prop = param
    }

    /// Returns a string value concatenating `param1` and `param2`.
    ///
    /// - Parameters:
    ///   - param1: An Int value for prefix.
    ///   - param2: A String value for suffix.
    ///
    /// - Returns: A string concatenating given params.
    func bar(param1: Int, param2: String) -> String {
        return "\(param1)" + param2
    }
}
```

## [Developer's Certificate of Origin 1.1](https://elinux.org/Developer_Certificate_Of_Origin)
By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
