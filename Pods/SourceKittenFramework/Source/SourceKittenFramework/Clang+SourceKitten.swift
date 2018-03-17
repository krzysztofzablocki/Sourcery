//
//  Clang+SourceKitten.swift
//  SourceKitten
//
//  Created by Thomas Goyne on 9/17/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif
import Foundation
import SWXMLHash

private var _interfaceUUIDMap = [String: String]()
private var _interfaceUUIDMapLock = NSLock()

/// Thread safe read from sourceKitUID map
private func uuidString(`for` sourceKitUID: String) -> String? {
    _interfaceUUIDMapLock.lock()
    defer { _interfaceUUIDMapLock.unlock() }
    return _interfaceUUIDMap[sourceKitUID]
}

/// Thread safe write from sourceKitUID map
private func setUUIDString(uidString: String, `for` file: String) {
    _interfaceUUIDMapLock.lock()
    defer { _interfaceUUIDMapLock.unlock() }
    _interfaceUUIDMap[file] = uidString
}

struct ClangIndex {
    private let index = clang_createIndex(0, 1)

    func open(file: String, args: [UnsafePointer<Int8>?]) -> CXTranslationUnit {
        return clang_createTranslationUnitFromSourceFile(index, file, Int32(args.count), args, 0, nil)!
    }
}

public struct ClangAvailability {
    public let alwaysDeprecated: Bool
    public let alwaysUnavailable: Bool
    public let deprecationMessage: String?
    public let unavailableMessage: String?
}

extension CXString: CustomStringConvertible {
    func str() -> String? {
        if let cString = clang_getCString(self) {
            return String(validatingUTF8: cString)
        }
        return nil
    }

    public var description: String {
        return str() ?? "<null>"
    }
}

extension CXTranslationUnit {
    func cursor() -> CXCursor {
        return clang_getTranslationUnitCursor(self)
    }
}

extension CXCursor {
    func location() -> SourceLocation {
        return SourceLocation(clangLocation: clang_getCursorLocation(self))
    }

    func extent() -> (start: SourceLocation, end: SourceLocation) {
        let extent = clang_getCursorExtent(self)
        let start = SourceLocation(clangLocation: clang_getRangeStart(extent))
        let end = SourceLocation(clangLocation: clang_getRangeEnd(extent))
        return (start, end)
    }

    func shouldDocument() -> Bool {
        return clang_isDeclaration(kind) != 0 &&
            kind != CXCursor_ParmDecl &&
            kind != CXCursor_TemplateTypeParameter &&
            clang_Location_isInSystemHeader(clang_getCursorLocation(self)) == 0
    }

    func declaration() -> String? {
        let comment = parsedComment()
        if comment.kind() == CXComment_Null {
            return str()
        }
        let commentXML = clang_FullComment_getAsXML(comment).str() ?? ""
        guard let rootXML = SWXMLHash.parse(commentXML).children.first else {
            fatalError("couldn't parse XML")
        }
        guard let text = rootXML["Declaration"].element?.text,
            !text.isEmpty else {
                return nil
        }
        return text
            .replacingOccurrences(of: "\n@end", with: "")
            .replacingOccurrences(of: "@property(", with: "@property (")
    }

    func objCKind() -> ObjCDeclarationKind {
        return ObjCDeclarationKind(kind)
    }

    func str() -> String? {
        let cursorExtent = extent()
        let contents = try! String(contentsOfFile: cursorExtent.start.file, encoding: .utf8)
        return contents.substringWithSourceRange(start: cursorExtent.start, end: cursorExtent.end)
    }

    func name() -> String {
        let type = objCKind()
        if type == .category, let usrNSString = usr() as NSString? {
            let ext = (usrNSString.range(of: "c:objc(ext)").location == 0)
            let regex = try! NSRegularExpression(pattern: "(\\w+)@(\\w+)", options: [])
            let range = NSRange(location: 0, length: usrNSString.length)
            let matches = regex.matches(in: usrNSString as String, options: [], range: range)
            if !matches.isEmpty {
                let categoryOn = usrNSString.substring(with: matches[0].range(at: 1))
                let categoryName = ext ? "" : usrNSString.substring(with: matches[0].range(at: 2))
                return "\(categoryOn)(\(categoryName))"
            } else {
                fatalError("Couldn't get category name")
            }
        }
        let spelling = clang_getCursorSpelling(self).str()!
        if type == .methodInstance {
            return "-" + spelling
        } else if type == .methodClass {
            return "+" + spelling
        }
        return spelling
    }

    func usr() -> String? {
        return clang_getCursorUSR(self).str()
    }

    func platformAvailability() -> ClangAvailability {
        var alwaysDeprecated: Int32 = 0
        var alwaysUnavailable: Int32 = 0
        var deprecationString = CXString()
        var unavailableString = CXString()

        _ = clang_getCursorPlatformAvailability(self,
                                                &alwaysDeprecated,
                                                &deprecationString,
                                                &alwaysUnavailable,
                                                &unavailableString,
                                                nil,
                                                0)
        return ClangAvailability(alwaysDeprecated: alwaysDeprecated != 0,
                                 alwaysUnavailable: alwaysUnavailable != 0,
                                 deprecationMessage: deprecationString.description,
                                 unavailableMessage: unavailableString.description)
    }

    func visit(_ block: @escaping (CXCursor, CXCursor) -> CXChildVisitResult) {
        _ = clang_visitChildrenWithBlock(self, block)
    }

    func parsedComment() -> CXComment {
        return clang_Cursor_getParsedComment(self)
    }

    func flatMap<T>(_ block: @escaping (CXCursor) -> T?) -> [T] {
        var ret = [T]()
        visit { cursor, _ in
            if let val = block(cursor) {
                ret.append(val)
            }
            return CXChildVisit_Continue
        }
        return ret
    }

    func commentBody() -> String? {
        let rawComment = clang_Cursor_getRawCommentText(self).str()
        let replacements = [
            "@param ": "- parameter: ",
            "@return ": "- returns: ",
            "@warning ": "- warning: ",
            "@see ": "- see: ",
            "@note ": "- note: "
        ]
        var commentBody = rawComment?.commentBody()
        for (original, replacement) in replacements {
            commentBody = commentBody?.replacingOccurrences(of: original, with: replacement)
        }
        return commentBody
    }

    func swiftDeclarationAndName(compilerArguments: [String]) -> (swiftDeclaration: String?, swiftName: String?) {
        let file = location().file
        let swiftUUID: String

        if let uuid = uuidString(for: file) {
            swiftUUID = uuid
        } else {
            swiftUUID = NSUUID().uuidString
            setUUIDString(uidString: swiftUUID, for: file)
            // Generate Swift interface, associating it with the UUID
            do {
                _ = try Request.interface(file: file, uuid: swiftUUID, arguments: compilerArguments).send()
            } catch {
                return (nil, nil)
            }
        }

        guard let usr = usr(),
            let findUSR = try? Request.findUSR(file: swiftUUID, usr: usr).send(),
            let usrOffset = findUSR[SwiftDocKey.offset.rawValue] as? Int64 else {
                return (nil, nil)
        }

        guard let cursorInfo = try? Request.cursorInfo(file: swiftUUID, offset: usrOffset, arguments: compilerArguments).send() else {
            return (nil, nil)
        }

        let swiftDeclaration = (cursorInfo[SwiftDocKey.annotatedDeclaration.rawValue] as? String)
            .flatMap(SWXMLHash.parse)?.element?.recursiveText

        let swiftName = cursorInfo[SwiftDocKey.name.rawValue] as? String

        return (swiftDeclaration, swiftName)
    }
}

extension CXComment {
    func paramName() -> String? {
        guard clang_Comment_getKind(self) == CXComment_ParamCommand else { return nil }
        return clang_ParamCommandComment_getParamName(self).str()
    }

    func paragraph() -> CXComment {
        return clang_BlockCommandComment_getParagraph(self)
    }

    func paragraphToString(kindString: String? = nil) -> [Text] {
        if kind() == CXComment_VerbatimLine {
            return [.verbatim(clang_VerbatimLineComment_getText(self).str()!)]
        } else if kind() == CXComment_BlockCommand {
            return (0..<count()).reduce([]) { returnValue, childIndex in
                return returnValue + self[childIndex].paragraphToString()
            }
        }

        guard kind() == CXComment_Paragraph else {
            print("not a paragraph: \(kind())")
            return []
        }

        let paragraphString = (0..<count()).reduce("") { paragraphString, childIndex in
            let child = self[childIndex]
            if let text = clang_TextComment_getText(child).str() {
                return paragraphString + (paragraphString != "" ? "\n" : "") + text
            } else if child.kind() == CXComment_InlineCommand {
                // @autoreleasepool etc. get parsed as commands when not in code blocks
                let inlineCommand = child.commandName().map { "@" + $0 }
                return paragraphString + (inlineCommand ?? "")
            }
            fatalError("not text: \(child.kind())")
        }
        return [.para(paragraphString.removingCommonLeadingWhitespaceFromLines(), kindString)]
    }

    func kind() -> CXCommentKind {
        return clang_Comment_getKind(self)
    }

    func commandName() -> String? {
        return clang_BlockCommandComment_getCommandName(self).str() ??
            clang_InlineCommandComment_getCommandName(self).str()
    }

    func count() -> UInt32 {
        return clang_Comment_getNumChildren(self)
    }

    subscript(idx: UInt32) -> CXComment {
        return clang_Comment_getChild(self, idx)
    }
}

#endif
