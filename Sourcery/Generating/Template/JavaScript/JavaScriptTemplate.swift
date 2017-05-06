import JavaScriptCore
import PathKit
import SourceryRuntime

final class JavaScriptTemplate: Template {

    let sourcePath: Path
    let template: String
    let jsContext: JSContext

    init(path: Path, context: JSContext = JSContext()) throws {
        template = try path.read()
        sourcePath = path
        jsContext = context
    }

    init(templateString: String) {
        self.template = templateString
        sourcePath = ""
        jsContext = JSContext()
    }

    func render(types: Types, arguments: [String : NSObject]) throws -> String {
        let context = TemplateContext(types: types, arguments: arguments)

        // swiftlint:disable:next force_unwrapping
        let path = Bundle(for: JavaScriptTemplate.self).path(forResource: "ejsbundle", ofType: "js")!
        let ejs = try String(contentsOfFile: path, encoding: .utf8)

        var error: Swift.Error?
        jsContext.exceptionHandler = { _, exception in
            error = exception?.toString() ?? "Unknown JavaScript error"
        }
        jsContext.setObject(template, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(sourcePath.lastComponent, forKeyedSubscript: "templateName" as NSString)
        jsContext.setObject(context.jsContext, forKeyedSubscript: "templateContext" as NSString)

        let valueForKey: @convention(block) (TypesCollection, String) -> Any? = { target, key in
            do {
                return try target.types(forKey: key)
            } catch let _error {
                error = _error
                return nil
            }
        }
        jsContext.setObject(valueForKey, forKeyedSubscript: "valueForKey" as NSString)
        jsContext.evaluateScript("templateContext.types.implementing = new Proxy(templateContext.types.implementing, { get: valueForKey })")
        jsContext.evaluateScript("templateContext.types.inheriting = new Proxy(templateContext.types.inheriting, { get: valueForKey })")
        jsContext.evaluateScript("templateContext.types.based = new Proxy(templateContext.types.based, { get: valueForKey })")

        let include: @convention(block) (String) -> [String:String] = { [unowned self] requestedPath in
            let requestedPath = Path(requestedPath)
            let path = self.sourcePath.parent() + requestedPath
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
        jsContext.setObject(include, forKeyedSubscript: "include" as NSString)

        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw "\(sourcePath): \(error)"
        }

        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

}
