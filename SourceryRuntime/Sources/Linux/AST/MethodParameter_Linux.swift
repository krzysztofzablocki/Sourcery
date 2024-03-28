#if !canImport(ObjectiveC)
import Foundation

/// Describes method parameter
public class MethodParameter: NSObject, SourceryModel, Typed, Annotated, Diffable, SourceryDynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "argumentLabel":
                return argumentLabel
            case "name":
                return name
            case "typeName":
                return typeName
            case "isClosure":
                return isClosure
            case "typeAttributes":
                return typeAttributes
            case "isVariadic":
                return isVariadic
            case "asSource":
                return asSource
            case "index":
                return index
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }
    /// Parameter external name
    public var argumentLabel: String?

    // Note: although method parameter can have no name, this property is not optional,
    // this is so to maintain compatibility with existing templates.
    /// Parameter internal name
    public let name: String

    /// Parameter type name
    public let typeName: TypeName

    /// Parameter flag whether it's inout or not
    public let `inout`: Bool

    /// Is this variadic parameter?
    public let isVariadic: Bool

    // sourcery: skipEquality, skipDescription
    /// Parameter type, if known
    public var type: Type?

    /// Parameter type attributes, i.e. `@escaping`
    public var typeAttributes: AttributeList {
        return typeName.attributes
    }

    /// Method parameter default value expression
    public var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    /// Method parameter index in the argument list
    public var index: Int

    /// :nodoc:
    public init(argumentLabel: String?, name: String = "", index: Int, typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:], isInout: Bool = false, isVariadic: Bool = false) {
        self.typeName = typeName
        self.argumentLabel = argumentLabel
        self.name = name
        self.index = index
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
        self.`inout` = isInout
        self.isVariadic = isVariadic
    }

    /// :nodoc:
    public init(name: String = "", index: Int, typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:], isInout: Bool = false, isVariadic: Bool = false) {
        self.typeName = typeName
        self.argumentLabel = name
        self.name = name
        self.index = index
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
        self.`inout` = isInout
        self.isVariadic = isVariadic
    }

    public var asSource: String {
        let values: String = defaultValue.map { " = \($0)" } ?? ""
        let variadicity: String = isVariadic ? "..." : ""
        let inoutness: String = `inout` ? "inout " : ""
        let typeSuffix = ": \(inoutness)\(typeName.asSource)\(values)\(variadicity)"
        guard argumentLabel != name else {
            return name + typeSuffix
        }

        let labels = [argumentLabel ?? "_", name.nilIfEmpty]
          .compactMap { $0 }
          .joined(separator: " ")

        return (labels.nilIfEmpty ?? "_") + typeSuffix
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string.append("argumentLabel = \(String(describing: self.argumentLabel)), ")
        string.append("name = \(String(describing: self.name)), ")
        string.append("typeName = \(String(describing: self.typeName)), ")
        string.append("`inout` = \(String(describing: self.`inout`)), ")
        string.append("isVariadic = \(String(describing: self.isVariadic)), ")
        string.append("typeAttributes = \(String(describing: self.typeAttributes)), ")
        string.append("defaultValue = \(String(describing: self.defaultValue)), ")
        string.append("annotations = \(String(describing: self.annotations)), ")
        string.append("asSource = \(String(describing: self.asSource)), ")
        string.append("index = \(String(describing: self.index))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? MethodParameter else {
            results.append("Incorrect type <expected: MethodParameter, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "argumentLabel").trackDifference(actual: self.argumentLabel, expected: castObject.argumentLabel))
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "`inout`").trackDifference(actual: self.`inout`, expected: castObject.`inout`))
        results.append(contentsOf: DiffableResult(identifier: "isVariadic").trackDifference(actual: self.isVariadic, expected: castObject.isVariadic))
        results.append(contentsOf: DiffableResult(identifier: "defaultValue").trackDifference(actual: self.defaultValue, expected: castObject.defaultValue))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "index").trackDifference(actual: self.index, expected: castObject.index))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.argumentLabel)
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.`inout`)
        hasher.combine(self.isVariadic)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MethodParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.isVariadic != rhs.isVariadic { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }

// sourcery:inline:MethodParameter.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.argumentLabel = aDecoder.decode(forKey: "argumentLabel")
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { 
                withVaList(["typeName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.typeName = typeName
            self.`inout` = aDecoder.decode(forKey: "`inout`")
            self.isVariadic = aDecoder.decode(forKey: "isVariadic")
            self.type = aDecoder.decode(forKey: "type")
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { 
                withVaList(["annotations"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.annotations = annotations
            self.index = aDecoder.decode(forKey: "index")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.argumentLabel, forKey: "argumentLabel")
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.`inout`, forKey: "`inout`")
            aCoder.encode(self.isVariadic, forKey: "isVariadic")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.index, forKey: "index")
        }
// sourcery:end
}

extension Array where Element == MethodParameter {
    public var asSource: String {
        "(\(map { $0.asSource }.joined(separator: ", ")))"
    }
}
#endif
