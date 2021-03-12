import Foundation
import SourceryRuntime
import SwiftSyntax

extension Attribute {
    convenience init(_ attribute: AttributeSyntax) {
        var arguments = [String: NSObject]()
        attribute.argument?.description
          .split(separator: ",")
          .enumerated()
          .forEach { (idx, part) in
              let components = part.split(separator: ":", maxSplits: 1)
              switch components.count {
              case 2:
                  arguments[components[0].trimmed] = components[1].replacingOccurrences(of: "\"", with: "").trimmed as NSString
              case 1:
                  arguments["\(idx)"] = components[0].replacingOccurrences(of: "\"", with: "").trimmed as NSString
              default:
                  Log.astError("Unrecognized attribute format \(attribute.argument?.description ?? "")")
                  return
              }
          }

        self.init(name: attribute.attributeName.text.trimmed, arguments: arguments, description: attribute.withoutTrivia().description.trimmed)
    }

    static func from(_ attributes: AttributeListSyntax?) -> AttributeList {
        let array = attributes?
          .compactMap { $0.as(AttributeSyntax.self) }
          .map(Attribute.init) ?? []

        var final = AttributeList()
        array.forEach { attribute in
            var attributes = final[attribute.name, default: []]
            attributes.append(attribute)
            final[attribute.name] = attributes
        }

        return final
    }
}
