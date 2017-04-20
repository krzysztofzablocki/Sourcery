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

        jsContext.exceptionHandler = {
            Log.error($0)
        }
        let logError: @convention(block) (JSValue) -> Void = { error in
            Log.error(error.toString())
        }
        jsContext.setObject(logError, forKeyedSubscript: "logError" as NSString)
        jsContext.setObject(template, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(context.jsContext, forKeyedSubscript: "templateContext" as NSString)

        let valueForUndefinedKey: @convention(block) (TypesCollection, String) -> Any? = { target, key in
            return target.value(forUndefinedKey: key)
        }
        jsContext.setObject(valueForUndefinedKey, forKeyedSubscript: "valueForUndefinedKey" as NSString)
        jsContext.evaluateScript("templateContext.types.implementing = new Proxy(templateContext.types.implementing, { get: valueForUndefinedKey })")
        jsContext.evaluateScript("templateContext.types.inheriting = new Proxy(templateContext.types.inheriting, { get: valueForUndefinedKey })")
        jsContext.evaluateScript("templateContext.types.based = new Proxy(templateContext.types.based, { get: valueForUndefinedKey })")

        jsContext.evaluateScript("var window = this; \(ejs)")
        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

}
