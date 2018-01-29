import SourceryJS
import SourceryRuntime
import JavaScriptCore

class JavaScriptTemplate: EJSTemplate, Template {

    override var context: [String: Any] {
        didSet {
            jsContext.catchTypesAccessErrors()
            jsContext.catchTemplateContextTypesUnknownProperties()
        }
    }

    func render(_ context: TemplateContext) throws -> String {
        return try render(context.jsContext)
    }

}

private extension JSContext {

    // this will catch errors accessing types through wrong collections (i.e. using `implementing` instead of `based`)
    func catchTypesAccessErrors() {
        let valueForKey: @convention(block) (TypesCollection, String) -> Any? = { target, key in
            do {
                return try target.types(forKey: key)
            } catch {
                JSContext.current().evaluateScript("throw \"\(error)\"")
                return nil
            }
        }
        setObject(valueForKey, forKeyedSubscript: "valueForKey" as NSString)
        evaluateScript("templateContext.types.implementing = new Proxy(templateContext.types.implementing, { get: valueForKey })")
        evaluateScript("templateContext.types.inheriting = new Proxy(templateContext.types.inheriting, { get: valueForKey })")
        evaluateScript("templateContext.types.based = new Proxy(templateContext.types.based, { get: valueForKey })")
    }

    // this will catch errors when accessing context types properties (i.e. using `implements` instead of `implementing`)
    func catchTemplateContextTypesUnknownProperties() {
        evaluateScript("""
            templateContext.types = new Proxy(templateContext.types, {
                get(target, propertyKey, receiver) {
                    if (!(propertyKey in target)) {
                        throw new TypeError('Unknown property `'+propertyKey+'`');
                    }
                    // Make sure we don’t block access to Object.prototype
                    return Reflect.get(target, propertyKey, receiver);
                }
            });
            """)
    }

}
