// https://github.com/apple/swift-package-manager/blob/ad69efd093c6bdfbfa8cac143959f0bb6c43f0c4/Sources/Basic/StringConversions.swift
import Foundation

private func inShellWhitelist(_ codeUnit: UInt8) -> Bool {
    switch codeUnit {
    case UInt8(ascii: "a") ... UInt8(ascii: "z"),
         UInt8(ascii: "A") ... UInt8(ascii: "Z"),
         UInt8(ascii: "0") ... UInt8(ascii: "9"),
         UInt8(ascii: "-"),
         UInt8(ascii: "_"),
         UInt8(ascii: "/"),
         UInt8(ascii: ":"),
         UInt8(ascii: "@"),
         UInt8(ascii: "%"),
         UInt8(ascii: "+"),
         UInt8(ascii: "="),
         UInt8(ascii: "."),
         UInt8(ascii: ","):
        return true
    default:
        return false
    }
}

extension String {
    /// Creates a shell escaped string. If the string does not need escaping, returns the original string.
    /// Otherwise escapes using single quotes. For example:
    /// hello -> hello, hello$world -> 'hello$world', input A -> 'input A'
    ///
    /// - Returns: Shell escaped string.
    func shellEscaped() -> String {
        // If all the characters in the string are in whitelist then no need to escape.
        guard let pos = utf8.firstIndex(where: { !inShellWhitelist($0) }) else {
            return self
        }

        // If there are no single quotes then we can just wrap the string around single quotes.
        guard let singleQuotePos = utf8[pos...].firstIndex(of: UInt8(ascii: "'")) else {
            return "'" + self + "'"
        }

        // Otherwise iterate and escape all the single quotes.
        var newString = "'" + String(self[..<singleQuotePos])

        for char in self[singleQuotePos...] {
            if char == "'" {
                newString += "'\\''"
            } else {
                newString += String(char)
            }
        }

        newString += "'"

        return newString
    }

    /// Shell escapes the current string. This method is mutating version of shellEscaped().
    mutating func shellEscape() {
        self = shellEscaped()
    }
}
