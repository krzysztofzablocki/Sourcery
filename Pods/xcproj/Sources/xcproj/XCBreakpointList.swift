import Foundation
import PathKit
import AEXML

// swiftlint:disable:next type_body_length
final public class XCBreakpointList {

    // MARK: - Breakpoint Proxy

    final public class BreakpointProxy {

        // MARK: - Breakpoint Content

        final public class BreakpointContent {

            // MARK: - Breakpoint Action Proxy

            final public class BreakpointActionProxy {

                // MARK: - Breakpoint Action Content

                final public class ActionContent {
                    public var consoleCommand: String?
                    public var message: String?
                    public var conveyanceType: String?
                    public var command: String?
                    public var arguments: String?
                    public var waitUntilDone: Bool?
                    public var script: String?
                    public var soundName: String?

                    public init(consoleCommand: String? = nil,
                                message: String? = nil,
                                conveyanceType: String? = nil,
                                command: String? = nil,
                                arguments: String? = nil,
                                waitUntilDone: Bool? = nil,
                                script: String? = nil,
                                soundName: String? = nil) {
                        self.consoleCommand = consoleCommand
                        self.message = message
                        self.conveyanceType = conveyanceType
                        self.command = command
                        self.arguments = arguments
                        self.waitUntilDone = waitUntilDone
                        self.script = script
                        self.soundName = soundName
                    }
                    init(element: AEXMLElement) throws {
                        consoleCommand = element.attributes["consoleCommand"]
                        message = element.attributes["message"]
                        conveyanceType = element.attributes["conveyanceType"]
                        command = element.attributes["command"]
                        arguments = element.attributes["arguments"]
                        if let waitUntilDoneString = element.attributes["waitUntilDone"] {
                            waitUntilDone = waitUntilDoneString == "YES"
                        }
                        script = element.attributes["script"]
                        soundName = element.attributes["soundName"]
                    }
                    fileprivate func xmlElement() -> AEXMLElement {
                        var attributes: [String: String] = [:]
                        attributes["consoleCommand"] = consoleCommand
                        attributes["message"] = message
                        attributes["conveyanceType"] = conveyanceType
                        attributes["command"] = command
                        attributes["arguments"] = arguments
                        if let waitUntilDone = waitUntilDone {
                            attributes["waitUntilDone"] = waitUntilDone ? "YES" : "NO"
                        }
                        attributes["script"] = script
                        attributes["soundName"] = soundName

                        let element = AEXMLElement(name: "ActionContent",
                                                   value: nil,
                                                   attributes: attributes)
                        return element
                    }
                }

                // MARK: - Breakpoint Action Extension ID

                public enum ActionExtensionID: String {
                    case debuggerCommand = "Xcode.BreakpointAction.DebuggerCommand"
                    case log = "Xcode.BreakpointAction.Log"
                    case shellCommand = "Xcode.BreakpointAction.ShellCommand"
                    case graphicsTrace = "Xcode.BreakpointAction.GraphicsTrace"
                    case appleScript = "Xcode.BreakpointAction.AppleScript"
                    case sound = "Xcode.BreakpointAction.Sound"
                    case openGLError = "Xcode.BreakpointAction.OpenGLError"
                }

                public var actionExtensionID: ActionExtensionID
                public var actionContent: ActionContent

                public init(actionExtensionID: ActionExtensionID,
                            actionContent: ActionContent) {
                    self.actionExtensionID = actionExtensionID
                    self.actionContent = actionContent
                }

                init(element: AEXMLElement) throws {
                    guard let actionExtensionIDString = element.attributes["ActionExtensionID"],
                        let actionExtensionID = ActionExtensionID(rawValue: actionExtensionIDString) else {
                            throw XCBreakpointListError.missing(property: "ActionExtensionID")
                    }
                    self.actionExtensionID = actionExtensionID
                    actionContent = try ActionContent(element: element["ActionContent"])
                }

                fileprivate func xmlElement() -> AEXMLElement {
                    let element = AEXMLElement(name: "BreakpointActionProxy",
                                               value: nil,
                                               attributes: ["ActionExtensionID": actionExtensionID.rawValue])
                    element.addChild(actionContent.xmlElement())
                    return element
                }
            }

            // MARK: - Breakpoint Location Proxy

            final public class BreakpointLocationProxy {

                public init() {}

                init(element: AEXMLElement) throws {}

                fileprivate func xmlElement() -> AEXMLElement {
                    let element = AEXMLElement(name: "BreakpointLocationProxy",
                                               value: nil,
                                               attributes: [:])
                    return element
                }
            }

            public var enabled: Bool
            public var ignoreCount: String
            public var continueAfterRunningActions: Bool
            public var filePath: String?
            public var timestamp: String?
            public var startingColumn: String?
            public var endingColumn: String?
            public var startingLine: String?
            public var endingLine: String?
            public var breakpointStackSelectionBehavior: String?
            public var symbol: String?
            public var module: String?
            public var scope: String?
            public var stopOnStyle: String?
            public var condition: String?
            public var actions: [BreakpointActionProxy]
            public var locations: [BreakpointLocationProxy]

            public init(enabled: Bool = true,
                        ignoreCount: String = "0",
                        continueAfterRunningActions: Bool = false,
                        filePath: String? = nil,
                        timestamp: String? = nil,
                        startingColumn: String? = nil,
                        endingColumn: String? = nil,
                        startingLine: String? = nil,
                        endingLine: String? = nil,
                        breakpointStackSelectionBehavior: String? = nil,
                        symbol: String? = nil,
                        module: String? = nil,
                        scope: String? = nil,
                        stopOnStyle: String? = nil,
                        condition: String? = nil,
                        actions: [BreakpointActionProxy] = [],
                        locations: [BreakpointLocationProxy] = []) {
                self.enabled = enabled
                self.ignoreCount = ignoreCount
                self.continueAfterRunningActions = continueAfterRunningActions
                self.filePath = filePath
                self.timestamp = timestamp
                self.startingColumn = startingColumn
                self.endingColumn = endingColumn
                self.startingLine = startingLine
                self.endingLine = endingLine
                self.breakpointStackSelectionBehavior = breakpointStackSelectionBehavior
                self.symbol = symbol
                self.module = module
                self.scope = scope
                self.stopOnStyle = stopOnStyle
                self.condition = condition
                self.actions = actions
                self.locations = locations
            }

            init(element: AEXMLElement) throws {
                enabled = element.attributes["shouldBeEnabled"] == "Yes"
                ignoreCount = element.attributes["ignoreCount"] ?? "0"
                continueAfterRunningActions = element.attributes["continueAfterRunningActions"] == "Yes"
                filePath = element.attributes["filePath"]
                timestamp = element.attributes["timestampString"]
                startingColumn = element.attributes["startingColumnNumber"]
                endingColumn = element.attributes["endingColumnNumber"]
                startingLine = element.attributes["startingLineNumber"]
                endingLine = element.attributes["endingLineNumber"]
                breakpointStackSelectionBehavior = element.attributes["breakpointStackSelectionBehavior"]
                symbol = element.attributes["symbolName"]
                module = element.attributes["moduleName"]
                scope = element.attributes["scope"]
                stopOnStyle = element.attributes["stopOnStyle"]
                condition = element.attributes["condition"]

                actions = try element["Actions"]["BreakpointActionProxy"]
                    .all?
                    .map(BreakpointActionProxy.init) ?? []
                locations = try element["Locations"]["BreakpointLocationProxy"]
                    .all?
                    .map(BreakpointLocationProxy.init) ?? []
            }
            fileprivate func xmlElement() -> AEXMLElement {
                var attributes: [String: String] = [:]
                attributes["shouldBeEnabled"] = enabled ? "Yes" : "No"
                attributes["ignoreCount"] = ignoreCount
                attributes["continueAfterRunningActions"] = continueAfterRunningActions ? "Yes" : "No"
                attributes["filePath"] = filePath
                attributes["timestampString"] = timestamp
                attributes["startingColumnNumber"] = startingColumn
                attributes["endingColumnNumber"] = endingColumn
                attributes["startingLineNumber"] = startingLine
                attributes["endingLineNumber"] = endingLine
                attributes["breakpointStackSelectionBehavior"] = breakpointStackSelectionBehavior
                attributes["symbolName"] = symbol
                attributes["moduleName"] = module
                attributes["scope"] = scope
                attributes["stopOnStyle"] = stopOnStyle
                attributes["condition"] = condition

                let element = AEXMLElement(name: "BreakpointContent",
                                           value: nil,
                                           attributes: attributes)

                let actions = AEXMLElement(name: "Actions", value: nil, attributes: [:])
                self.actions.map({ $0.xmlElement() }).forEach({ actions.addChild($0) })
                element.addChild(actions)

                let locations = AEXMLElement(name: "Locations", value: nil, attributes: [:])
                self.locations.map({ $0.xmlElement() }).forEach({ locations.addChild($0) })
                element.addChild(locations)

                return element
            }
        }

        // MARK: - Breakpoint Extension ID

        public enum BreakpointExtensionID: String {
            case file = "Xcode.Breakpoint.FileBreakpoint"
            case exception = "Xcode.Breakpoint.ExceptionBreakpoint"
            case swiftError = "Xcode.Breakpoint.SwiftErrorBreakpoint"
            case openGLError = "Xcode.Breakpoint.OpenGLErrorBreakpoint"
            case symbolic = "Xcode.Breakpoint.SymbolicBreakpoint"
            case ideConstraintError = "Xcode.Breakpoint.IDEConstraintErrorBreakpoint"
            case ideTestFailure = "Xcode.Breakpoint.IDETestFailureBreakpoint"
        }

        public var breakpointExtensionID: BreakpointExtensionID
        public var breakpointContent: BreakpointContent

        public init(breakpointExtensionID: BreakpointExtensionID,
                    breakpointContent: BreakpointContent) {
            self.breakpointExtensionID = breakpointExtensionID
            self.breakpointContent = breakpointContent
        }

        init(element: AEXMLElement) throws {
            guard let breakpointExtensionIDString = element.attributes["BreakpointExtensionID"],
                let breakpointExtensionID = BreakpointExtensionID(rawValue: breakpointExtensionIDString) else {
                throw XCBreakpointListError.missing(property: "BreakpointExtensionID")
            }
            self.breakpointExtensionID = breakpointExtensionID
            breakpointContent = try BreakpointContent(element: element["BreakpointContent"])
        }

        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BreakpointProxy",
                                       value: nil,
                                       attributes: ["BreakpointExtensionID": breakpointExtensionID.rawValue])
            element.addChild(breakpointContent.xmlElement())
            return element
        }
    }

    // MARK: - Properties

    public var breakpoints: [BreakpointProxy]
    public var type: String?
    public var version: String?

    // MARK: - Init

    /// Initializes the breakpoints reading the content from the disk.
    ///
    /// - Parameters:
    ///   - path: breakpoints path.
    public init(path: Path) throws {
        if !path.exists {
            throw XCBreakpointListError.notFound(path: path)
        }
        let document = try AEXMLDocument(xml: try path.read())
        let bucket = document["Bucket"]
        type = bucket.attributes["type"]
        version = bucket.attributes["version"]
        breakpoints = try bucket["Breakpoints"]["BreakpointProxy"]
            .all?
            .map(BreakpointProxy.init) ?? []
    }

    public init(type: String? = nil,
                version: String? = nil,
                breakpoints: [BreakpointProxy] = []) {
        self.type = type
        self.version = version
        self.breakpoints = breakpoints
    }

    public func add(breakpointProxy: BreakpointProxy) -> XCBreakpointList {
        var breakpoints = self.breakpoints
        breakpoints.append(breakpointProxy)
        return XCBreakpointList(type: type, version: version, breakpoints: breakpoints)
    }

}

// MARK: - XCBreakpointList Extension (Writable)

extension XCBreakpointList: Writable {

    public func write(path: Path, override: Bool) throws {
        let document = AEXMLDocument()
        var schemeAttributes: [String: String] = [:]
        schemeAttributes["type"] = type
        schemeAttributes["version"] = version
        let bucket = document.addChild(name: "Bucket", value: nil, attributes: schemeAttributes)

        let breakpoints = AEXMLElement(name: "Breakpoints", value: nil, attributes: [:])
        self.breakpoints.map({ $0.xmlElement() }).forEach({ breakpoints.addChild($0) })
        bucket.addChild(breakpoints)

        if override && path.exists {
            try path.delete()
        }
        try path.write(document.xmlXcodeFormat)
    }

}

// MARK: - XCBreakpointList Errors.

/// XCBreakpointList Errors.
///
/// - notFound: returned when the Breakpoints_v2.xcbkptlist cannot be found.
/// - missing: returned when there's a property missing in the Breakpoints_v2.xcbkptlist.
public enum XCBreakpointListError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case missing(property: String)

    public var description: String {
        switch self {
        case .notFound(let path):
            return "Breakpoints_v2.xcbkptlist couldn't be found at path \(path)"
        case .missing(let property):
            return "Property \(property) missing"
        }
    }
}
