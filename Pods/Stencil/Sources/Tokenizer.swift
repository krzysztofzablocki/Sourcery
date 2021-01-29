import Foundation

extension String {
  /// Split a string by a separator leaving quoted phrases together
  func smartSplit(separator: Character = " ") -> [String] {
    var word = ""
    var components: [String] = []
    var separate: Character = separator
    var singleQuoteCount = 0
    var doubleQuoteCount = 0

    for character in self {
      if character == "'" {
        singleQuoteCount += 1
      } else if character == "\"" {
        doubleQuoteCount += 1
      }

      if character == separate {
        if separate != separator {
          word.append(separate)
        } else if (singleQuoteCount % 2 == 0 || doubleQuoteCount % 2 == 0) && !word.isEmpty {
          appendWord(word, to: &components)
          word = ""
        }

        separate = separator
      } else {
        if separate == separator && (character == "'" || character == "\"") {
          separate = character
        }
        word.append(character)
      }
    }

    if !word.isEmpty {
      appendWord(word, to: &components)
    }

    return components
  }

  private func appendWord(_ word: String, to components: inout [String]) {
    let specialCharacters = ",|:"

    if !components.isEmpty {
      if let precedingChar = components.last?.last, specialCharacters.contains(precedingChar) {
        components[components.count - 1] += word
      } else if specialCharacters.contains(word) {
        components[components.count - 1] += word
      } else if word != "(" && word.first == "(" || word != ")" && word.first == ")" {
        components.append(String(word.prefix(1)))
        appendWord(String(word.dropFirst()), to: &components)
      } else if word != "(" && word.last == "(" || word != ")" && word.last == ")" {
        appendWord(String(word.dropLast()), to: &components)
        components.append(String(word.suffix(1)))
      } else {
        components.append(word)
      }
    } else {
      components.append(word)
    }
  }
}

public struct SourceMap: Equatable {
  public let filename: String?
  public let location: ContentLocation

  init(filename: String? = nil, location: ContentLocation = ("", 0, 0)) {
    self.filename = filename
    self.location = location
  }

  static let unknown = SourceMap()

  public static func == (lhs: SourceMap, rhs: SourceMap) -> Bool {
    return lhs.filename == rhs.filename && lhs.location == rhs.location
  }
}

public class Token: Equatable {
  public enum Kind: Equatable {
    /// A token representing a piece of text.
    case text
    /// A token representing a variable.
    case variable
    /// A token representing a comment.
    case comment
    /// A token representing a template block.
    case block
  }

  public let contents: String
  public let kind: Kind
  public let sourceMap: SourceMap

  /// Returns the underlying value as an array seperated by spaces
  public private(set) lazy var components: [String] = self.contents.smartSplit()

  init(contents: String, kind: Kind, sourceMap: SourceMap) {
    self.contents = contents
    self.kind = kind
    self.sourceMap = sourceMap
  }

  /// A token representing a piece of text.
  public static func text(value: String, at sourceMap: SourceMap) -> Token {
    return Token(contents: value, kind: .text, sourceMap: sourceMap)
  }

  /// A token representing a variable.
  public static func variable(value: String, at sourceMap: SourceMap) -> Token {
    return Token(contents: value, kind: .variable, sourceMap: sourceMap)
  }

  /// A token representing a comment.
  public static func comment(value: String, at sourceMap: SourceMap) -> Token {
    return Token(contents: value, kind: .comment, sourceMap: sourceMap)
  }

  /// A token representing a template block.
  public static func block(value: String, at sourceMap: SourceMap) -> Token {
    return Token(contents: value, kind: .block, sourceMap: sourceMap)
  }

  public static func == (lhs: Token, rhs: Token) -> Bool {
    return lhs.contents == rhs.contents && lhs.kind == rhs.kind && lhs.sourceMap == rhs.sourceMap
  }
}
