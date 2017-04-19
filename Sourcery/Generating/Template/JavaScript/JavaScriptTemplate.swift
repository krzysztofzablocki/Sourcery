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

        var errorContent = ""

        let include: @convention(block) (String) -> String? = { [unowned self] path in
            let path = self.sourcePath.parent() + Path(path)
            let includedTemplate: String? = try? path.read()
            return includedTemplate
        }

        let rethrow: @convention(block) (NSDictionary, String, String, String) -> Void = { error, source, filename, lineno in
            errorContent += "// error parsing \(filename):\(lineno)\n"
        }

        jsContext.setObject(template, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(context.jsContext, forKeyedSubscript: "templateContext" as NSString)
        jsContext.setObject(include, forKeyedSubscript: "include" as NSString)
        jsContext.setObject(rethrow, forKeyedSubscript: "rethrow" as NSString)
        jsContext.setObject(sourcePath.lastComponent, forKeyedSubscript: "templateName" as NSString)
        jsContext.evaluateScript("var window = this; \(ejs)")
        let content = jsContext.objectForKeyedSubscript("content").toString()
        return errorContent + (content ?? "")
    }

}
