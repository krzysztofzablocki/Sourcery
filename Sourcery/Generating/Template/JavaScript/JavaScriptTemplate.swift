import JavaScriptCore
import PathKit

struct JavaScriptTemplateError: Error, CustomStringConvertible {
    var exception: JSValue?

    init(_ exception: JSValue?) {
        self.exception = exception
    }

    var description: String {
        let message = exception?.forProperty("message").toString() ?? "no message"

        return message
    }
}

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

        var error: JavaScriptTemplateError?

        let include: @convention(block) (String) -> String? = { [unowned self] path in
            let path = self.sourcePath.parent() + Path(path)
            let includedTemplate: String? = try? path.read()
            return includedTemplate
        }

        let exceptionHandler: (JSContext?, JSValue?) -> Void = { context, exception in
            error = JavaScriptTemplateError(exception)
        }

        jsContext.setObject(template, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(context.jsContext, forKeyedSubscript: "templateContext" as NSString)
        jsContext.setObject(include, forKeyedSubscript: "include" as NSString)
        jsContext.setObject(sourcePath.lastComponent, forKeyedSubscript: "templateName" as NSString)
        jsContext.exceptionHandler = exceptionHandler
        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw error
        }

        let content: String
        if let contentObject = jsContext.objectForKeyedSubscript("content"), contentObject.isString {
            content = contentObject.toString()
        } else {
            content = ""
        }

        return content
    }

}
