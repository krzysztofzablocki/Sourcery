import Foundation

/// Defines import type
#if canImport(ObjectiveC)
@objcMembers
#endif
public class Import: NSObject, SourceryModelWithoutDescription, Diffable {
    /// Import kind, e.g. class, struct in `import class Module.ClassName`
    public var kind: String?

    /// Import path
    public var path: String

    /// :nodoc:
    public init(path: String, kind: String? = nil) {
        self.path = path
        self.kind = kind
    }

    /// Full import value e.g. `import struct Module.StructName`
    public override var description: String {
        if let kind = kind {
            return "\(kind) \(path)"
        }

        return path
    }

    /// Returns module name from a import, e.g. if you had `import struct Module.Submodule.Struct` it will return `Module.Submodule`
    public var moduleName: String {
        if kind != nil {
            if let idx = path.lastIndex(of: ".") {
                return String(path[..<idx])
            } else {
                return path
            }
        } else {
            return path
        }
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Import else {
            results.append("Incorrect type <expected: Import, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "kind").trackDifference(actual: self.kind, expected: castObject.kind))
        results.append(contentsOf: DiffableResult(identifier: "path").trackDifference(actual: self.path, expected: castObject.path))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.kind)
        hasher.combine(self.path)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Import else { return false }
        if self.kind != rhs.kind { return false }
        if self.path != rhs.path { return false }
        return true
    }

// sourcery:inline:Import.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.kind = aDecoder.decode(forKey: "kind")
            guard let path: String = aDecoder.decode(forKey: "path") else { 
                withVaList(["path"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.path = path
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.kind, forKey: "kind")
            aCoder.encode(self.path, forKey: "path")
        }

// sourcery:end
}
