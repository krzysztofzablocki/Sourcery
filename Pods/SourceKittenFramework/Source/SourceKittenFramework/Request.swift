//
//  Request.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

import Dispatch
import Foundation
#if SWIFT_PACKAGE
import SourceKit
#endif

// swiftlint:disable file_length
// This file could easily be split up

public protocol SourceKitRepresentable {
    func isEqualTo(_ rhs: SourceKitRepresentable) -> Bool
}
extension Array: SourceKitRepresentable {}
extension Dictionary: SourceKitRepresentable {}
extension String: SourceKitRepresentable {}
extension Int64: SourceKitRepresentable {}
extension Bool: SourceKitRepresentable {}

extension SourceKitRepresentable {
    public func isEqualTo(_ rhs: SourceKitRepresentable) -> Bool {
        switch self {
        case let lhs as [SourceKitRepresentable]:
            for (idx, value) in lhs.enumerated() {
                if let rhs = rhs as? [SourceKitRepresentable], rhs[idx].isEqualTo(value) {
                    continue
                }
                return false
            }
            return true
        case let lhs as [String: SourceKitRepresentable]:
            for (key, value) in lhs {
                if let rhs = rhs as? [String: SourceKitRepresentable],
                   let rhsValue = rhs[key], rhsValue.isEqualTo(value) {
                    continue
                }
                return false
            }
            return true
        case let lhs as String:
            return lhs == rhs as? String
        case let lhs as Int64:
            return lhs == rhs as? Int64
        case let lhs as Bool:
            return lhs == rhs as? Bool
        default:
            fatalError("Should never happen because we've checked all SourceKitRepresentable types")
        }
    }
}

private func fromSourceKit(_ sourcekitObject: sourcekitd_variant_t) -> SourceKitRepresentable? {
    switch sourcekitd_variant_get_type(sourcekitObject) {
    case SOURCEKITD_VARIANT_TYPE_ARRAY:
        var array = [SourceKitRepresentable]()
        _ = withUnsafeMutablePointer(to: &array) { arrayPtr in
            sourcekitd_variant_array_apply_f(sourcekitObject, { index, value, context in
                if let value = fromSourceKit(value), let context = context {
                    let localArray = context.assumingMemoryBound(to: [SourceKitRepresentable].self)
                    localArray.pointee.insert(value, at: Int(index))
                }
                return true
            }, arrayPtr)
        }
        return array
    case SOURCEKITD_VARIANT_TYPE_DICTIONARY:
        var dict = [String: SourceKitRepresentable]()
        _ = withUnsafeMutablePointer(to: &dict) { dictPtr in
            sourcekitd_variant_dictionary_apply_f(sourcekitObject, { key, value, context in
                if let key = String(sourceKitUID: key!), let value = fromSourceKit(value), let context = context {
                    let localDict = context.assumingMemoryBound(to: [String: SourceKitRepresentable].self)
                    localDict.pointee[key] = value
                }
                return true
            }, dictPtr)
        }
        return dict
    case SOURCEKITD_VARIANT_TYPE_STRING:
        return String(cString: sourcekitd_variant_string_get_ptr(sourcekitObject)!)
    case SOURCEKITD_VARIANT_TYPE_INT64:
        return sourcekitd_variant_int64_get_value(sourcekitObject)
    case SOURCEKITD_VARIANT_TYPE_BOOL:
        return sourcekitd_variant_bool_get_value(sourcekitObject)
    case SOURCEKITD_VARIANT_TYPE_UID:
        return String(sourceKitUID: sourcekitd_variant_uid_get_value(sourcekitObject)!)
    case SOURCEKITD_VARIANT_TYPE_NULL:
        return nil
    default:
        fatalError("Should never happen because we've checked all SourceKitRepresentable types")
    }
}

/// Lazily and singly computed Void constants to initialize SourceKit once per session.
private let initializeSourceKit: Void = {
    sourcekitd_initialize()
}()
private let initializeSourceKitFailable: Void = {
    initializeSourceKit
    sourcekitd_set_notification_handler { response in
        if !sourcekitd_response_is_error(response!) {
            fflush(stdout)
            fputs("sourcekitten: connection to SourceKitService restored!\n", stderr)
            sourceKitWaitingRestoredSemaphore.signal()
        }
        sourcekitd_response_dispose(response!)
    }
}()

/// dispatch_semaphore_t used when waiting for sourcekitd to be restored.
private var sourceKitWaitingRestoredSemaphore = DispatchSemaphore(value: 0)

private extension String {
    /**
    Cache SourceKit requests for strings from UIDs

    - returns: Cached UID string if available, nil otherwise.
    */
    init?(sourceKitUID: sourcekitd_uid_t) {
        let bytes = sourcekitd_uid_get_string_ptr(sourceKitUID)
        self = String(cString: bytes!)
        return
    }
}

/// Represents a SourceKit request.
public enum Request {
    /// An `editor.open` request for the given File.
    case editorOpen(file: File)
    /// A `cursorinfo` request for an offset in the given file, using the `arguments` given.
    case cursorInfo(file: String, offset: Int64, arguments: [String])
    /// A custom request by passing in the `SourceKitObject` directly.
    case customRequest(request: SourceKitObject)
    /// A request generated by sourcekit using the yaml representation.
    case yamlRequest(yaml: String)
    /// A `codecomplete` request by passing in the file name, contents, offset
    /// for which to generate code completion options and array of compiler arguments.
    case codeCompletionRequest(file: String, contents: String, offset: Int64, arguments: [String])
    /// ObjC Swift Interface
    case interface(file: String, uuid: String, arguments: [String])
    /// Find USR
    case findUSR(file: String, usr: String)
    /// Index
    case index(file: String, arguments: [String])
    /// Format
    case format(file: String, line: Int64, useTabs: Bool, indentWidth: Int64)
    /// ReplaceText
    case replaceText(file: String, offset: Int64, length: Int64, sourceText: String)
    /// A documentation request for the given source text.
    case docInfo(text: String, arguments: [String])
    /// A documentation request for the given module.
    case moduleInfo(module: String, arguments: [String])

    fileprivate var sourcekitObject: SourceKitObject {
        switch self {
        case .editorOpen(let file):
            if let path = file.path {
                return [
                    "key.request": UID("source.request.editor.open"),
                    "key.name": path,
                    "key.sourcefile": path
                ]
            } else {
                return [
                    "key.request": UID("source.request.editor.open"),
                    "key.name": String(file.contents.hash),
                    "key.sourcetext": file.contents
                ]
            }
        case .cursorInfo(let file, let offset, let arguments):
            return [
                "key.request": UID("source.request.cursorinfo"),
                "key.name": file,
                "key.sourcefile": file,
                "key.offset": offset,
                "key.compilerargs": arguments
            ]
        case .customRequest(let request):
            return request
        case .yamlRequest(let yaml):
            return .init(sourcekitd_request_create_from_yaml(yaml, nil)!)
        case .codeCompletionRequest(let file, let contents, let offset, let arguments):
            return [
                "key.request": UID("source.request.codecomplete"),
                "key.name": file,
                "key.sourcefile": file,
                "key.sourcetext": contents,
                "key.offset": offset,
                "key.compilerargs": arguments
            ]
        case .interface(let file, let uuid, var arguments):
            if !arguments.contains("-x") {
                arguments.append(contentsOf: ["-x", "objective-c"])
            }
            if !arguments.contains("-isysroot") {
                arguments.append(contentsOf: ["-isysroot", sdkPath()])
            }
            return [
                "key.request": UID("source.request.editor.open.interface.header"),
                "key.name": uuid,
                "key.filepath": file,
                "key.compilerargs": [file] + arguments
            ]
        case .findUSR(let file, let usr):
            return [
                "key.request": UID("source.request.editor.find_usr"),
                "key.usr": usr,
                "key.sourcefile": file
            ]
        case .index(let file, let arguments):
            return [
                "key.request": UID("source.request.indexsource"),
                "key.sourcefile": file,
                "key.compilerargs": arguments
            ]
        case .format(let file, let line, let useTabs, let indentWidth):
            return [
                "key.request": UID("source.request.editor.formattext"),
                "key.name": file,
                "key.line": line,
                "key.editor.format.options": [
                    "key.editor.format.indentwidth": indentWidth,
                    "key.editor.format.tabwidth": indentWidth,
                    "key.editor.format.usetabs": useTabs ? 1 : 0
                ]
            ]
        case .replaceText(let file, let offset, let length, let sourceText):
            return [
                "key.request": UID("source.request.editor.replacetext"),
                "key.name": file,
                "key.offset": offset,
                "key.length": length,
                "key.sourcetext": sourceText
            ]
        case .docInfo(let text, let arguments):
            return [
                "key.request": UID("source.request.docinfo"),
                "key.name": NSUUID().uuidString,
                "key.compilerargs": arguments,
                "key.sourcetext": text
            ]
        case .moduleInfo(let module, let arguments):
            return [
                "key.request": UID("source.request.docinfo"),
                "key.name": NSUUID().uuidString,
                "key.compilerargs": arguments,
                "key.modulename": module
            ]
        }
    }

    /**
    Create a Request.CursorInfo.sourcekitObject() from a file path and compiler arguments.

    - parameter filePath:  Path of the file to create request.
    - parameter arguments: Compiler arguments.

    - returns: sourcekitd_object_t representation of the Request, if successful.
    */
    internal static func cursorInfoRequest(filePath: String?, arguments: [String]) -> SourceKitObject? {
        if let path = filePath {
            return Request.cursorInfo(file: path, offset: 0, arguments: arguments).sourcekitObject
        }
        return nil
    }

    /**
    Send a Request.CursorInfo by updating its offset. Returns SourceKit response if successful.

    - parameter cursorInfoRequest: sourcekitd_object_t representation of Request.CursorInfo
    - parameter offset:            Offset to update request.

    - returns: SourceKit response if successful.
    */
    internal static func send(cursorInfoRequest: SourceKitObject, atOffset offset: Int64) -> [String: SourceKitRepresentable]? {
        if offset == 0 {
            return nil
        }
        cursorInfoRequest.updateValue(offset, forKey: SwiftDocKey.offset)
        return try? Request.customRequest(request: cursorInfoRequest).send()
    }

    /**
    Sends the request to SourceKit and return the response as an [String: SourceKitRepresentable].

    - returns: SourceKit output as a dictionary.
    - throws: Request.Error on fail ()
    */
    public func send() throws -> [String: SourceKitRepresentable] {
        initializeSourceKitFailable
        let response = sourcekitd_send_request_sync(sourcekitObject.sourcekitdObject!)
        defer { sourcekitd_response_dispose(response!) }
        if sourcekitd_response_is_error(response!) {
            let error = Request.Error(response: response!)
            if case .connectionInterrupted = error {
                _ = sourceKitWaitingRestoredSemaphore.wait(timeout: DispatchTime.now() + 10)
            }
            throw error
        }
        return fromSourceKit(sourcekitd_response_get_value(response!)) as! [String: SourceKitRepresentable]
    }

    /// A enum representation of SOURCEKITD_ERROR_*
    public enum Error: Swift.Error, CustomStringConvertible {
        case connectionInterrupted(String?)
        case invalid(String?)
        case failed(String?)
        case cancelled(String?)
        case unknown(String?)

        /// A textual representation of `self`.
        public var description: String {
            return getDescription() ?? "no description"
        }

        private func getDescription() -> String? {
            switch self {
            case .connectionInterrupted(let string): return string
            case .invalid(let string): return string
            case .failed(let string): return string
            case .cancelled(let string): return string
            case .unknown(let string): return string
            }
        }

        fileprivate init(response: sourcekitd_response_t) {
            let description = String(validatingUTF8: sourcekitd_response_error_get_description(response)!)
            switch sourcekitd_response_error_get_kind(response) {
            case SOURCEKITD_ERROR_CONNECTION_INTERRUPTED: self = .connectionInterrupted(description)
            case SOURCEKITD_ERROR_REQUEST_INVALID: self = .invalid(description)
            case SOURCEKITD_ERROR_REQUEST_FAILED: self = .failed(description)
            case SOURCEKITD_ERROR_REQUEST_CANCELLED: self = .cancelled(description)
            default: self = .unknown(description)
            }
        }
    }

    /**
    Sends the request to SourceKit and return the response as an [String: SourceKitRepresentable].

    - returns: SourceKit output as a dictionary.
    - throws: Request.Error on fail ()
    */
    @available(*, deprecated, renamed: "send()")
    public func failableSend() throws -> [String: SourceKitRepresentable] {
        return try send()
    }
}

// MARK: CustomStringConvertible

extension Request: CustomStringConvertible {
    /// A textual representation of `Request`.
    public var description: String { return sourcekitObject.description }
}

private func interfaceForModule(_ module: String, compilerArguments: [String]) throws -> [String: SourceKitRepresentable] {
    return try Request.customRequest(request: [
        "key.request": UID("source.request.editor.open.interface"),
        "key.name": NSUUID().uuidString,
        "key.compilerargs": compilerArguments,
        "key.modulename": "SourceKittenFramework.\(module)"
    ]).send()
}

extension String {
    private func nameFromFullFunctionName() -> String {
        return String(self[..<range(of: "(")!.lowerBound])
    }

    fileprivate func extractFreeFunctions(inSubstructure substructure: [[String: SourceKitRepresentable]]) -> [String] {
        return substructure.filter({
            SwiftDeclarationKind(rawValue: SwiftDocKey.getKind($0)!) == .functionFree
        }).compactMap { function -> String? in
            let name = (function["key.name"] as! String).nameFromFullFunctionName()
            let unsupportedFunctions = [
                "clang_executeOnThread",
                "sourcekitd_variant_dictionary_apply",
                "sourcekitd_variant_array_apply"
            ]
            guard !unsupportedFunctions.contains(name) else {
                return nil
            }

            let parameters = SwiftDocKey.getSubstructure(function)?.map { parameterStructure in
                return parameterStructure["key.typename"] as! String
            } ?? []
            var returnTypes = [String]()
            if let offset = SwiftDocKey.getOffset(function), let length = SwiftDocKey.getLength(function) {
                let start = index(startIndex, offsetBy: Int(offset))
                let end = index(start, offsetBy: Int(length))
#if swift(>=4.0)
                let functionDeclaration = String(self[start..<end])
#else
                let functionDeclaration = self[start..<end]
#endif
                if let startOfReturnArrow = functionDeclaration.range(of: "->", options: .backwards)?.lowerBound {
                    let adjustedDistance = distance(from: startIndex, to: startOfReturnArrow)
                    let adjustedReturnTypeStartIndex = functionDeclaration.index(functionDeclaration.startIndex,
                                                                                 offsetBy: adjustedDistance + 3)
                    returnTypes.append(String(functionDeclaration[adjustedReturnTypeStartIndex...]))
                }
            }

            let joinedParameters = parameters.map({ $0.replacingOccurrences(of: "!", with: "?") }).joined(separator: ", ")
            let joinedReturnTypes = returnTypes.map({ $0.replacingOccurrences(of: "!", with: "?") }).joined(separator: ", ")
            let lhs = "internal let \(name): @convention(c) (\(joinedParameters)) -> (\(joinedReturnTypes))"
            let rhs = "library.load(symbol: \"\(name)\")"
            return "\(lhs) = \(rhs)".replacingOccurrences(of: "SourceKittenFramework.", with: "")
        }
    }
}

internal func libraryWrapperForModule(_ module: String, loadPath: String, linuxPath: String?, spmModule: String, compilerArguments: [String]) throws -> String {
    let sourceKitResponse = try interfaceForModule(module, compilerArguments: compilerArguments)
    let substructure = SwiftDocKey.getSubstructure(Structure(sourceKitResponse: sourceKitResponse).dictionary)!
    let source = sourceKitResponse["key.sourcetext"] as! String
    let freeFunctions = source.extractFreeFunctions(inSubstructure: substructure)
    let spmImport = "#if SWIFT_PACKAGE\nimport \(spmModule)\n#endif\n"
    let library: String
    if let linuxPath = linuxPath {
        library = "#if os(Linux)\n" +
            "private let path = \"\(linuxPath)\"\n" +
            "#else\n" +
            "private let path = \"\(loadPath)\"\n" +
            "#endif\n" +
            "private let library = toolchainLoader.load(path: path)\n"
    } else {
        library = "private let library = toolchainLoader.load(path: \"\(loadPath)\")\n"
    }
    let startPlatformCheck: String
    let endPlatformCheck: String
    if linuxPath == nil {
        startPlatformCheck = "#if !os(Linux)\n"
        endPlatformCheck = "\n#endif\n"
    } else {
        startPlatformCheck = ""
        endPlatformCheck = "\n"
    }
    return startPlatformCheck + spmImport + library + freeFunctions.joined(separator: "\n") + endPlatformCheck
}
