import Foundation
import SourceryRuntime
import SwiftSyntax

extension Attribute {
    convenience init(_ attribute: AttributeSyntax) {
        var arguments = [String: NSObject]()
        attribute.arguments?.description
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
                  Log.astError("Unrecognized attribute format \(attribute.arguments?.description ?? "")")
                  return
              }
          }

        self.init(name: attribute.attributeName.description.trimmed, arguments: arguments,  description: attribute.withoutTrivia().description.trimmed)
    }

    static func from(_ attributes: AttributeListSyntax?) -> AttributeList {
        let array = attributes?
          .compactMap { syntax -> Attribute? in
            if let syntax = syntax.as(AttributeSyntax.self) {
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

    var isComma: Bool {
        switch self {
        case .comma:
            return true
        default:
            return false
        }
    }
}

private extension LabeledExprSyntax {
    /// Returns key and value strings for a tuple element. If the tuple does not have an argument label,
    /// `nil` will be returned for the key.
    var keyAndValue: (key: String?, value: String) {
        var iterator = tokens(viewMode: .fixedUp).makeIterator()
        if let argumentLabelToken = iterator.next(),
           let colonToken = iterator.next(),
           case let .identifier(argumentLabel) = argumentLabelToken.tokenKind,
           colonToken.tokenKind == .colon {
            // This argument has a label
            let valueText = getConcatenatedTokenText(iterator: &iterator)
            return (argumentLabel.trimmed, valueText)
        } else {
            // This argument does not have a label
            iterator = tokens(viewMode: .fixedUp).makeIterator()
            let valueText = getConcatenatedTokenText(iterator: &iterator)
            return (nil, valueText)
        }
    }

    private func getConcatenatedTokenText(iterator: inout TokenSequence.Iterator) -> String {
        var valueText = ""
        var lastTokenWasComma = false
        while let nextToken = iterator.next() {
            lastTokenWasComma = nextToken.tokenKind.isComma
            valueText += nextToken.text.trimmed
        }

        valueText = valueText.replacingOccurrences(of: "\"", with: "").trimmed
        if lastTokenWasComma && valueText.hasSuffix(",") {
            valueText.remove(at: valueText.index(before: valueText.endIndex))
        }
        return valueText
    }
}
