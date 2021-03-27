import Foundation
import SourceryRuntime
import SwiftSyntax

protocol AttributeSyntaxType {
    var argumentDescription: String? { get }
    var nameText: String { get }
    var descriptionWithoutTrivia: String { get }
}

extension AttributeSyntaxType where Self: SyntaxProtocol {
    var descriptionWithoutTrivia: String {
        withoutTrivia().description.trimmed
    }
}

extension AttributeSyntax: AttributeSyntaxType {
    var argumentDescription: String? {
        argument?.description
    }

    var nameText: String {
        attributeName.text.trimmed
    }
}

extension CustomAttributeSyntax: AttributeSyntaxType {
    var argumentDescription: String? {
        argumentList?.description
    }

    var nameText: String {
        tokens.first(where: { syntax in
            switch syntax.tokenKind {
            case .identifier:
                return true
            default:
                return false
            }
        })?.text.trimmed ?? ""
    }
}

extension Attribute {
    convenience init(_ attribute: AttributeSyntaxType) {
        var arguments = [String: NSObject]()
        attribute.argumentDescription?
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
                  Log.astError("Unrecognized attribute format \(attribute.argumentDescription ?? "")")
                  return
              }
          }

        self.init(name: attribute.nameText, arguments: arguments, description: attribute.descriptionWithoutTrivia)
    }

    static func from(_ attributes: AttributeListSyntax?) -> AttributeList {
        let array = attributes?
          .compactMap { syntax -> AttributeSyntaxType? in
            syntax.as(AttributeSyntax.self) ?? syntax.as(CustomAttributeSyntax.self)
          }
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
