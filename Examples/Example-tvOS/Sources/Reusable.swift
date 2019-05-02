protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(reflecting: self)
    }
}

typealias NibReusable = NibLoadable & Reusable
