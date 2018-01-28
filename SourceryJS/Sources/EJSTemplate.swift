import JavaScriptCore
import PathKit
import SourceryRuntime

open class EJSTemplate {

    public let sourcePath: Path
    public let templateString: String

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

    public init(path: Path, context: JSContext = JSContext()) throws {
        templateString = try path.read()
        sourcePath = path
    }

    public init(templateString: String) {
        self.templateString = templateString
        sourcePath = ""
    }

    public func render(_ context: [String: Any]) throws -> String {
        self.context = context

        var error: Swift.Error?
        jsContext.exceptionHandler = {
            error = error ?? $1?.toString() ?? "Unknown JavaScript error"
        }

        // swiftlint:disable:next force_unwrapping
        let path = Bundle(for: EJSTemplate.self).path(forResource: "ejsbundle", ofType: "js")!
        let ejs = try String(contentsOfFile: path, encoding: .utf8)
        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw "\(sourcePath): \(error)"
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
