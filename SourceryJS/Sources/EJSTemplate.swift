import JavaScriptCore
import PathKit

open class EJSTemplate {

    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
        public init(_ value: String) {
            self.description = value
        }
    }

    /// Should be set to the path of EJS before rendering any template.
    /// By default reads ejsbundle.js from framework bundle.
    /// If framework is built with SPM this property should be set manually.
    public static var ejsPath: Path! = Bundle(for: EJSTemplate.self).path(forResource: "ejs", ofType: "js").map({ Path($0) })

    public let sourcePath: Path
    public let templateString: String
    let ejs: String

    public private(set) lazy var jsContext: JSContext = {
        let jsContext = JSContext()!
        jsContext.setObject(self.templateString, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(self.sourcePath.lastComponent, forKeyedSubscript: "templateName" as NSString)
        jsContext.setObject(self.context, forKeyedSubscript: "templateContext" as NSString)
        let include: @convention(block) (String) -> [String:String] = { [unowned self] in self.includeFile($0) }
        jsContext.setObject(include, forKeyedSubscript: "include" as NSString)
        return jsContext
    }()

    open var context: [String: Any] = [:] {
        didSet {
            jsContext.setObject(context, forKeyedSubscript: "templateContext" as NSString)
        }
    }

    public init(path: Path, ejsPath: Path = EJSTemplate.ejsPath) throws {
        templateString = try path.read()
        sourcePath = path
        self.ejs = try ejsPath.read(.utf8)
    }

    public init(templateString: String, ejsPath: Path = EJSTemplate.ejsPath) throws {
        self.templateString = templateString
        sourcePath = ""
        self.ejs = try ejsPath.read(.utf8)
    }

    public func render(_ context: [String: Any]) throws -> String {
        self.context = context

        var error: Error?
        jsContext.exceptionHandler = {
            error = error ?? $1.map({ Error($0.toString()) }) ?? Error("Unknown JavaScript error")
        }

        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw Error("\(sourcePath): \(error)")
        }

        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

    func includeFile(_ requestedPath: String) -> [String: String] {
        let requestedPath = Path(requestedPath)
        let path = sourcePath.parent() + requestedPath
        var includedTemplate: String? = try? path.read()

        /// The template extension may be omitted, so try to read again by adding it if a template was not found
        if includedTemplate == nil, path.extension != "ejs" {
            includedTemplate = try? Path(path.string + ".ejs").read()
        }

        var templateDictionary = [String: String]()
        templateDictionary["template"] = includedTemplate
        if requestedPath.components.count > 1 {
            templateDictionary["basePath"] = Path(components: requestedPath.components.dropLast()).string
        }

        return templateDictionary
    }

}
