import JavaScriptCore
import PathKit

final class JavaScriptTemplate: Template {

    let sourcePath: Path
    let template: String
    let jsContext: JSContext

    init(path: Path, context: JSContext = JSContext()) throws {
        template = try path.read()
        sourcePath = path
        jsContext = context
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
        jsContext.setObject(context.jsContext, forKeyedSubscript: "templateContext" as NSString)

        let valueForKey: @convention(block) (TypesCollection, String) -> Any? = { target, key in
            do {
                return try target.valueForKey(target, key)
            } catch let _error {
                error = _error
                return nil
            }
        }
        jsContext.setObject(valueForKey, forKeyedSubscript: "valueForKey" as NSString)
        jsContext.evaluateScript("templateContext.types.implementing = new Proxy(templateContext.types.implementing, { get: valueForKey })")
        jsContext.evaluateScript("templateContext.types.inheriting = new Proxy(templateContext.types.inheriting, { get: valueForKey })")
        jsContext.evaluateScript("templateContext.types.based = new Proxy(templateContext.types.based, { get: valueForKey })")

        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw "\(sourcePath): \(error)"
        }

        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

}
