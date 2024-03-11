import Foundation

public typealias SourceryModifier = Modifier
/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
#if canImport(ObjectiveC)
@objcMembers
#endif
public class Modifier: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport, Diffable {

    /// The declaration modifier name.
    public let name: String

    /// The modifier detail, if any.
    public let detail: String?

    public init(name: String, detail: String? = nil) {
        self.name = name
        self.detail = detail
    }

    public var asSource: String {
        if let detail = detail {
            return "\(name)(\(detail))"
        } else {
            return name
        }
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Modifier else {
            results.append("Incorrect type <expected: Modifier, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "detail").trackDifference(actual: self.detail, expected: castObject.detail))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.detail)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Modifier else { return false }
        if self.name != rhs.name { return false }
        if self.detail != rhs.detail { return false }
        return true
    }

    // sourcery:inline:Modifier.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let name: String = aDecoder.decode(forKey: "name") else { 
                    withVaList(["name"]) { arguments in
                        NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                    }
                    fatalError()
                 }; self.name = name
                self.detail = aDecoder.decode(forKey: "detail")
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.name, forKey: "name")
                aCoder.encode(self.detail, forKey: "detail")
            }
    // sourcery:end
}
