import Foundation

public typealias SourceryModifier = Modifier
/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
@objcMembers public class Modifier: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

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

    // sourcery:inline:Modifier.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
                self.detail = aDecoder.decode(forKey: "detail")
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.name, forKey: "name")
                aCoder.encode(self.detail, forKey: "detail")
            }
    // sourcery:end
}
