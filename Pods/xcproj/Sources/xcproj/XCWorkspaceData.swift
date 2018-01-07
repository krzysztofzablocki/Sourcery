import Foundation
import PathKit
import AEXML

final public class XCWorkspaceData {

    public var children: [XCWorkspaceDataElement]

    public init(children: [XCWorkspaceDataElement]) {
        self.children = children
    }
}

extension XCWorkspaceData: Equatable {

    public static func == (lhs: XCWorkspaceData, rhs: XCWorkspaceData) -> Bool {
        return rhs.children == rhs.children
    }
}

extension XCWorkspaceData: Writable {

    /// Initializes the workspace with the path where the workspace is.
    /// The initializer will try to find an .xcworkspacedata inside the workspace.
    /// If the .xcworkspacedata cannot be found, the init will fail.
    ///
    /// - Parameter path: .xcworkspace path.
    /// - Throws: throws an error if the workspace cannot be initialized.
    public convenience init(path: Path) throws {
        if !path.exists {
            throw XCWorkspaceDataError.notFound(path: path)
        }

        let xml = try AEXMLDocument(xml: path.read())
        let children = try xml
            .root
            .children
            .flatMap(XCWorkspaceDataElement.init(element:))

        self.init(children: children)
    }

    // MARK: - <Writable>

    public func write(path: Path, override: Bool = true) throws {
        let document = AEXMLDocument()
        let workspace = document.addChild(name: "Workspace", value: nil, attributes: ["version": "1.0"])
        _ = children
            .map({ $0.xmlElement() })
            .map(workspace.addChild)

        if override && path.exists {
            try path.delete()
        }
        try path.write(document.xmlXcodeFormat)
    }
}

// MARK: - XCWorkspaceData Errors

/// XCWorkspaceData Errors.
///
/// - notFound: returned when the .xcworkspacedata cannot be found.
public enum XCWorkspaceDataError: Error, CustomStringConvertible {

    case notFound(path: Path)

    public var description: String {
        switch self {
        case .notFound(let path):
            return "Workspace not found at \(path)"
        }
    }

}


// MARK: - XCWorkspaceDataElement AEXMLElement decoding and encoding

fileprivate extension XCWorkspaceDataElement {

    init(element: AEXMLElement) throws {
        switch element.name {
        case "FileRef":
            self = try .file(XCWorkspaceDataFileRef(element: element))
        case "Group":
            self = try .group(XCWorkspaceDataGroup(element: element))
        default:
            throw Error.unknownName(element.name)
        }
    }

    fileprivate func xmlElement() -> AEXMLElement {
        switch self {
        case .file(let fileRef):
            return fileRef.xmlElement()
        case .group(let group):
            return group.xmlElement()
        }
    }
}

// MARK: - XCWorkspaceDataGroup AEXMLElement decoding and encoding

fileprivate extension XCWorkspaceDataGroup {
    enum Error: Swift.Error {
        case wrongElementName
        case missingLocationAttribute
    }

    convenience init(element: AEXMLElement) throws {
        guard element.name == "Group" else {
            throw Error.wrongElementName
        }
        guard let location = element.attributes["location"] else {
            throw Error.missingLocationAttribute
        }
        let locationType = try XCWorkspaceDataElementLocationType(string: location)
        let name = element.attributes["name"]
        let children = try element.children.map(XCWorkspaceDataElement.init(element:))
        self.init(location: locationType, name: name, children: children)
    }

    func xmlElement() -> AEXMLElement {
        var attributes = ["location": location.description]
        attributes["name"] = name
        let element = AEXMLElement(name: "Group", value: nil, attributes: attributes)

        _ = children
            .map({ $0.xmlElement() })
            .map(element.addChild)

        return element
    }
}

// MARK: - XCWorkspaceDataFileRef AEXMLElement decoding and encoding

fileprivate extension XCWorkspaceDataFileRef {
    enum Error: Swift.Error {
        case wrongElementName
        case missingLocationAttribute
    }

    convenience init(element: AEXMLElement) throws {
        guard element.name == "FileRef" else {
            throw Error.wrongElementName
        }
        guard let location = element.attributes["location"] else {
            throw Error.missingLocationAttribute
        }
        self.init(location: try XCWorkspaceDataElementLocationType(string: location))
    }

    func xmlElement() -> AEXMLElement {
        return AEXMLElement(name: "FileRef",
                            value: nil,
                            attributes: ["location": location.description])
    }
}
