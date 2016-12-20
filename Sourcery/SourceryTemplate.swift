import Foundation
import Stencil
import PathKit

internal class SourceryTemplate: Template {
    private(set) var sourcePath: Path = ""
    convenience init(path: Path) throws {
        self.init(templateString: try path.read(), environment: SourceryTemplate.sourceryEnvironment())
        sourcePath = path
    }
    
    convenience init(templateString: String) {
        self.init(templateString: templateString, environment: SourceryTemplate.sourceryEnvironment())
    }
    
    private static func sourceryEnvironment() -> Stencil.Environment {
        let ext = Stencil.Extension()
        ext.registerFilter("upperFirst", filter: upperFirstFilter)
        ext.registerFilter("contains", filter: stringContentFilter("contains", String.contains))
        ext.registerFilter("hasPrefix", filter: stringContentFilter("hasPrefix", String.hasPrefix))
        ext.registerFilter("hasSuffix", filter: stringContentFilter("hasSuffix", String.hasSuffix))
        
        return Stencil.Environment(extensions: [ext])
    }
}

private func upperFirstFilter(_ value: Any?) -> Any? {
    guard let string = value as? String else {
        return value
    }
    let first = String(string.characters.prefix(1)).capitalized
    let other = String(string.characters.dropFirst())
    return first + other
}

private func stringContentFilter(_ name: String, _ filter: @escaping (String) -> (String) -> Bool) -> (Any?, [Any?]) throws -> Any? {
    return { (any, args) throws -> Any? in
        guard args.count == 1, let arg = args.first as? String else {
            throw TemplateSyntaxError("'\(name)' filter takes a single string argument")
        }
        guard let s = any as? String else {
            return any
        }
        return filter(s)(arg)
    }
}

