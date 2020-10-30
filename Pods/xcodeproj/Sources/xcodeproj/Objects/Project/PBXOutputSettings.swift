import Foundation

/// Code for controlling sorting of files in an pbxproj file.

// MARK: - Core sort functions

// Because of the number of optional data items in PBXBuildFiles, we've externalised the core code in these two functions.
// Note, PBXBuildFile's contains PBXFileElements so this first function is an optional handling wrapper driving the second.
// Also note that we use the .fileName() function to retrieve the name as both .path and .name properties can be nil.

private func sortUsingNames(_ lhs: PBXBuildFile, _ rhs: PBXBuildFile) -> Bool {
    if let lhsFile = lhs.file, let rhsFile = rhs.file {
        return sortUsingNames(lhsFile, rhsFile)
    }
    return lhs.uuid < rhs.uuid
}

private func sortUsingNames(_ lhs: PBXFileElement, _ rhs: PBXFileElement) -> Bool {
    if let lhsFilename = lhs.fileName(), let rhsFilename = rhs.fileName() {
        return lhsFilename == rhsFilename ? lhs.uuid < rhs.uuid : lhsFilename < rhsFilename
    }
    return lhs.uuid < rhs.uuid
}

// MARK: - Sorting enums

/// Defines the sorting applied to files within the file lists. Defaults to by UUID.
public enum PBXFileOrder {
    /// Sort files by Xcode's UUID
    case byUUID

    /// Sort files by their file name. This is a case sensistive sort with lower case names coming after uppercase names.
    case byFilename

    internal func sort<Object>(lhs: (PBXObjectReference, Object), rhs: (PBXObjectReference, Object)) -> Bool
        where Object: PlistSerializable & Equatable {
        return lhs.0 < rhs.0
    }

    internal func sort(lhs: (PBXObjectReference, PBXBuildFile), rhs: (PBXObjectReference, PBXBuildFile)) -> Bool {
        switch self {
        case .byFilename:
            return sortUsingNames(lhs.1, rhs.1)
        default:
            return lhs.0 < rhs.0
        }
    }

    internal func sort(lhs: (PBXObjectReference, PBXBuildPhaseFile), rhs: (PBXObjectReference, PBXBuildPhaseFile)) -> Bool {
        switch self {
        case .byFilename:
            return sortUsingNames(lhs.1.buildFile, rhs.1.buildFile)
        default:
            return lhs.0 < rhs.0
        }
    }

    internal func sort(lhs: (PBXObjectReference, PBXFileReference), rhs: (PBXObjectReference, PBXFileReference)) -> Bool {
        switch self {
        case .byFilename:
            return sortUsingNames(lhs.1, rhs.1)

        default:
            return lhs.0 < rhs.0
        }
    }
}

private extension PBXFileElement {
    var isGroup: Bool {
        switch self {
        case is PBXVariantGroup, is XCVersionGroup: return false
        case is PBXGroup: return true
        default: return false
        }
    }
}

/// Defines the sorting applied to groups with the project navigator and various build phases.
public enum PBXNavigatorFileOrder {
    /// Leave the files unsorted.
    case unsorted

    /// Sort the file by their file name. This is a case sensitive sort with uppercase name preceeding lowercase names.
    case byFilename

    /// Sorts the files by their file names with all groups appear at the top of the list.
    case byFilenameGroupsFirst

    internal var sort: ((PBXFileElement, PBXFileElement) -> Bool)? {
        switch self {
        case .byFilename:
            return { sortUsingNames($0, $1) }

        case .byFilenameGroupsFirst:
            return { lhs, rhs in
                let lhsIsGroup = lhs.isGroup
                if lhsIsGroup != rhs.isGroup {
                    return lhsIsGroup
                }
                return sortUsingNames(lhs, rhs)
            }

        default:
            return nil // Don't sort.
        }
    }
}

/// Defines the sorting of file within a build phase.
public enum PBXBuildPhaseFileOrder {
    /// Leave the files unsorted.
    case unsorted

    /// Sort the files by their file name. This is a case sensitive sort with uppercase names appearing before lowercase names.
    case byFilename

    internal var sort: ((PBXBuildFile, PBXBuildFile) -> Bool)? {
        switch self {
        case .byFilename:
            return { lhs, rhs in
                sortUsingNames(lhs, rhs)
            }

        default:
            return nil // Don't sort.
        }
    }
}

/// Defines the format of project file references
public enum PBXReferenceFormat {
    /// Adds prefix and suffix characters to the references.
    /// The prefix characters identify the type of reference generated (e.g. BP for Build Phase).
    /// The suffix number is only added for uniqueness if clashes occur.
    case withPrefixAndSuffix
    /// Standard 24 char format that XCode generates.
    /// Note: Not guaranteed to be the same as XCode generates - only the format is the same.
    case xcode
}

/// Struct of output settings passed to various methods.
public struct PBXOutputSettings {
    /// The sorting order for the list of files in Xcode's project file.
    let projFileListOrder: PBXFileOrder

    /// The sort order for files and groups that appear in the Xcode Project Navigator.
    let projNavigatorFileOrder: PBXNavigatorFileOrder

    /// The sort order for lists of files in build phases.
    let projBuildPhaseFileOrder: PBXBuildPhaseFileOrder

    /// The format of project file references
    let projReferenceFormat: PBXReferenceFormat

    /**
     Default initializer

     - Parameter projFileListOrder: Defines the sort order for internal file lists in the project file.
     - Parameter projNavigatorFileOrder: Defines the order of files in the project navigator groups.
     - Parameter projBuildPhaseFileOrder: Defines the sort order of files in build phases.
     */
    public init(projFileListOrder: PBXFileOrder = .byUUID,
                projNavigatorFileOrder: PBXNavigatorFileOrder = .unsorted,
                projBuildPhaseFileOrder: PBXBuildPhaseFileOrder = .unsorted,
                projReferenceFormat: PBXReferenceFormat = .xcode) {
        self.projFileListOrder = projFileListOrder
        self.projNavigatorFileOrder = projNavigatorFileOrder
        self.projBuildPhaseFileOrder = projBuildPhaseFileOrder
        self.projReferenceFormat = projReferenceFormat
    }
}
