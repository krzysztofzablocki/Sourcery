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

    convenience init(_ attribute: CustomAttributeSyntax) {
        let nameText = attribute.tokens
            .first(where: \.tokenKind.isIdentifier)?
            .text
            .trimmed ?? ""

        let arguments = attribute.argumentList?
            .reduce(into: [String: NSObject]()) { arguments, syntax in
                var iterator = syntax.tokens.makeIterator()
                guard let argumentLabelToken = iterator.next(),
                      let colonToken = iterator.next(),
                      case let .identifier(argumentLabel) = argumentLabelToken.tokenKind,
                      colonToken.tokenKind == .colon
                else { return }

                var valueText = ""
                while let nextToken = iterator.next() { valueText += nextToken.text.trimmed }
                arguments[argumentLabel.trimmed] = valueText.replacingOccurrences(of: "\"", with: "").trimmed as NSString
            } ?? [:]

        self.init(name: nameText, arguments: arguments, description: attribute.withoutTrivia().description.trimmed)
    }

    static func from(_ attributes: AttributeListSyntax?) -> AttributeList {
        let array = attributes?
          .compactMap { syntax -> Attribute? in
            if let syntax = syntax.as(AttributeSyntax.self) {
                return Attribute(syntax)
            } else if let syntax = syntax.as(CustomAttributeSyntax.self) {
                return Attribute(syntax)
            } else {
                return nil
            }
          } ?? []

        var final = AttributeList()
        array.forEach { attribute in
            var attributes = final[attribute.name, default: []]
            attributes.append(attribute)
            final[attribute.name] = attributes
        }

        return final
    }
}

private extension TokenKind {
    var isIdentifier: Bool {
        switch self {
        case .identifier:
            return true
        default:
            return false
        }
    }
}
