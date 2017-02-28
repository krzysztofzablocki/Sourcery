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

    func render(types: [Type], arguments: [String : NSObject]) throws -> String {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        let typesBox = TypesReflectionBox(types: types)

        let context: [String: Any] = [
            "types": [
                "classes": typesBox.classes,
                "all": typesBox.all,
                "protocols": typesBox.protocols,
                "structs": typesBox.structs,
                "enums": typesBox.enums,
                "based": typesBox.based,
                "inheriting": typesBox.inheriting,
                "implementing": typesBox.implementing
            ],
            "type": typesByName,
            "argument": arguments
        ]

        // swiftlint:disable:next force_unwrapping
        let path = Bundle(for: JavaScriptTemplate.self).path(forResource: "ejsbundle", ofType: "js")!
        let ejs = try String(contentsOfFile: path, encoding: .utf8)

        jsContext.setObject(template, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(context, forKeyedSubscript: "templateContext" as NSString)
        jsContext.evaluateScript("var window = this; \(ejs)")
        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

}
