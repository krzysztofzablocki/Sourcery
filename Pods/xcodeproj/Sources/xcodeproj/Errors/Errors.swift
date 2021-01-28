import Foundation
import PathKit

// MARK: - Xcodeproj

/// XcodeProj Errors
///
/// - notFound: the project cannot be found.
/// - pbxProjNotFound: the .pbxproj file couldn't be found inside the project folder.
/// - xcworkspaceNotFound: the workspace cannot be found at the given path.
public enum XCodeProjError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case pbxprojNotFound(path: Path)
    case xcworkspaceNotFound(path: Path)

    public var description: String {
        switch self {
        case let .notFound(path):
            return "The project cannot be found at \(path.string)"
        case let .pbxprojNotFound(path):
            return "The project doesn't contain a .pbxproj file at path: \(path.string)"
        case let .xcworkspaceNotFound(path):
            return "The project doesn't contain a .xcworkspace at path: \(path.string)"
        }
    }
}

// MARK: - XCSharedData

/// XCSharedData errors.
///
/// - notFound: the share data hasn't been found.
public enum XCSharedDataError: Error, CustomStringConvertible {
    case notFound(path: Path)

    public var description: String {
        switch self {
        case let .notFound(path):
            return "xcshareddata not found at path \(path.string)"
        }
    }
}

// MARK: - XCWorkspace

/// XCWorkspace Errors
///
/// - notFound: the project cannot be found.
public enum XCWorkspaceError: Error, CustomStringConvertible {
    case notFound(path: Path)

    public var description: String {
        switch self {
        case let .notFound(path):
            return "The project cannot be found at \(path.string)"
        }
    }
}

// MARK: - XCWorkspaceData

/// XCWorkspaceData Errors.
///
/// - notFound: returned when the .xcworkspacedata cannot be found.
public enum XCWorkspaceDataError: Error, CustomStringConvertible {
    case notFound(path: Path)

    public var description: String {
        switch self {
        case let .notFound(path):
            return "Workspace not found at \(path.string)"
        }
    }
}

// MARK: - Xcodeproj Editing

/// Xcodeproj editing errors.
///
/// - unexistingFile: the file doesn't exist.
public enum XcodeprojEditingError: Error, CustomStringConvertible {
    case unexistingFile(Path)

    public var description: String {
        switch self {
        case let .unexistingFile(path):
            return "The file at path \(path.string) doesn't exist"
        }
    }
}

// MARK: - Xcodeproj Writing

/// Xcodeproj writing error.
///
/// - invalidType: the type that is being written is invalid.
public enum XcodeprojWritingError: Error, CustomStringConvertible {
    case invalidType(class: String, expected: String)

    public var description: String {
        switch self {
        case let .invalidType(classType, expected):
            return "Invalid type for object \(classType) that expects a \(expected)"
        }
    }
}

// MARK: - PBXObject

/// PBXObject error.
///
/// - missingIsa: the isa attribute is missing.
/// - unknownElement: the element that is being parsed is not supported.
/// - objectsReleased: the project has been released or the object hasn't been added to any project.
/// - objectNotFound: the object annot be found in the project.
/// - orphaned: the object doesn't belong to any project.
public enum PBXObjectError: Error, CustomStringConvertible {
    case missingIsa
    case unknownElement(String)
    case objectsReleased
    case objectNotFound(String)
    case orphaned(type: String, reference: String)

    public var description: String {
        switch self {
        case .missingIsa:
            return "Isa property is missing."
        case let .unknownElement(element):
            return "The element \(element) is not supported."
        case .objectsReleased:
            return "The PBXObjects instance has been released before saving."
        case let .objectNotFound(reference):
            return "PBXObject with reference \"\(reference)\" not found."
        case let .orphaned(type, reference):
            return "Trying to use object \(type) with reference '\(reference)' before being added to any project"
        }
    }
}

// MARK: - PBXProjEncoder

/// PBXProjEncoder error.
///
/// - emptyProjectReference: the project reference is missing.
enum PBXProjEncoderError: Error, CustomStringConvertible {
    case emptyProjectReference

    var description: String {
        switch self {
        case .emptyProjectReference:
            return "PBXProj should contain a reference to the XcodeProj object that represents the project"
        }
    }
}

// MARK: - PBXProj

/// PBXProj error.
///
/// - notFound: the .pbxproj cannot be found at the given path.
enum PBXProjError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case invalidGroupPath(sourceRoot: Path, elementPath: String?)
    var description: String {
        switch self {
        case let .notFound(path):
            return ".pbxproj not found at path \(path.string)"
        case let .invalidGroupPath(sourceRoot, elementPath):
            return "Cannot calculate full path for file element \"\(elementPath ?? "")\" in source root: \"\(sourceRoot)\""
        }
    }
}

// MARK: - XCBreakpointList

/// XCBreakpointList error.
///
/// - notFound: returned when the Breakpoints_v2.xcbkptlist cannot be found.
/// - missing: returned when there's a property missing in the Breakpoints_v2.xcbkptlist.
public enum XCBreakpointListError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case missing(property: String)

    public var description: String {
        switch self {
        case let .notFound(path):
            return "Breakpoints_v2.xcbkptlist couldn't be found at path \(path.string)"
        case let .missing(property):
            return "Property \(property) missing"
        }
    }
}

// MARK: - XCConfig

/// XCConfig errors.
///
/// - notFound: returned when the configuration file couldn't be found.
public enum XCConfigError: Error, CustomStringConvertible {
    case notFound(path: Path)
    public var description: String {
        switch self {
        case let .notFound(path):
            return ".xcconfig file not found at \(path.string)"
        }
    }
}
