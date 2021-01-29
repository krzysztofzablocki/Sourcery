import Foundation
import PathKit

public class PBXGroup: PBXFileElement {
    // MARK: - Attributes

    /// Group children references.
    var childrenReferences: [PBXObjectReference]

    /// Group children.
    public var children: [PBXFileElement] {
        set {
            childrenReferences = newValue.references()
        }
        get {
            childrenReferences.objects()
        }
    }

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - children: group children.
    ///   - sourceTree: group source tree.
    ///   - name: group name.
    ///   - path: group relative path from `sourceTree`, if different than `name`.
    ///   - includeInIndex: should the IDE index the files in the group?
    ///   - wrapsLines: should the IDE wrap lines for files in the group?
    ///   - usesTabs: group uses tabs.
    ///   - indentWidth: the number of positions to indent blocks of code
    ///   - tabWidth: the visual width of tab characters
    public init(children: [PBXFileElement] = [],
                sourceTree: PBXSourceTree? = nil,
                name: String? = nil,
                path: String? = nil,
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil) {
        childrenReferences = children.references()
        super.init(sourceTree: sourceTree,
                   path: path,
                   name: name,
                   includeInIndex: includeInIndex,
                   usesTabs: usesTabs,
                   indentWidth: indentWidth,
                   tabWidth: tabWidth,
                   wrapsLines: wrapsLines)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case children
    }

    public required init(from decoder: Decoder) throws {
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let childrenReferences: [String] = (try container.decodeIfPresent(.children)) ?? []
        self.childrenReferences = childrenReferences.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }
        try super.init(from: decoder)
    }

    // MARK: - PlistSerializable

    override func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(type(of: self).isa))
        dictionary["children"] = .array(childrenReferences.map { (fileReference) -> PlistValue in
            let fileElement: PBXFileElement? = fileReference.getObject()
            return .string(CommentedString(fileReference.value, comment: fileElement?.fileName()))
        })

        return (key: CommentedString(reference,
                                     comment: name ?? path),
                value: .dictionary(dictionary))
    }

    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXGroup else { return false }
        return isEqual(to: rhs)
    }
}

// MARK: - Helpers

/// Options passed when adding new groups.
public struct GroupAddingOptions: OptionSet {
    /// Raw value.
    public let rawValue: Int

    /// Initializes the options with the raw value.
    ///
    /// - Parameter rawValue: raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Create group without reference to folder
    public static let withoutFolder = GroupAddingOptions(rawValue: 1 << 0)
}

public extension PBXGroup {
    /// Returns group with the given name contained in the given parent group.
    ///
    /// - Parameter groupName: group name.
    /// - Returns: group with the given name contained in the given parent group.
    func group(named name: String) -> PBXGroup? {
        childrenReferences
            .objects()
            .first(where: { $0.name == name })
    }

    /// Returns the file in the group with the given name.
    ///
    /// - Parameter name: file name.
    /// - Returns: file with the given name contained in the given parent group.
    func file(named name: String) -> PBXFileReference? {
        childrenReferences
            .objects()
            .first(where: { $0.name == name })
    }

    /// Creates a group with the given name and returns it.
    ///
    /// - Parameters:
    ///   - groupName: group name.
    ///   - options: creation options.
    /// - Returns: created groups.
    @discardableResult
    func addGroup(named groupName: String, options: GroupAddingOptions = []) throws -> [PBXGroup] {
        let objects = try self.objects()
        return groupName.components(separatedBy: "/").reduce(into: [PBXGroup]()) { groups, name in
            let group = groups.last ?? self
            let newGroup = PBXGroup(children: [], sourceTree: .group, name: name, path: options.contains(.withoutFolder) ? nil : name)
            newGroup.parent = self
            group.childrenReferences.append(newGroup.reference)
            objects.add(object: newGroup)
            groups.append(newGroup)
        }
    }

    /// Creates a variant group with the given name and returns it.
    ///
    /// - Parameters:
    ///   - groupName: group name.
    /// - Returns: created groups.
    @discardableResult
    func addVariantGroup(named groupName: String) throws -> [PBXVariantGroup] {
        let objects = try self.objects()

        return groupName.components(separatedBy: "/").reduce(into: [PBXVariantGroup]()) { groups, name in
            let group = groups.last ?? self
            let newGroup = PBXVariantGroup(children: [], sourceTree: .group, name: name)
            newGroup.parent = self
            group.childrenReferences.append(newGroup.reference)
            objects.add(object: newGroup)
            groups.append(newGroup)
        }
    }

    /// Adds file at the give path to the project or returns existing file and its reference.
    ///
    /// - Parameters:
    ///   - filePath: path to the file.
    ///   - sourceTree: file sourceTree, default is `.group`.
    ///   - sourceRoot: path to project's source root.
    ///   - override: flag to enable overriding of existing file references, default is `true`.
    ///   - validatePresence: flag to validate the existence of the file in the file system, default is `true`.
    /// - Returns: new or existing file and its reference.
    @discardableResult
    func addFile(
        at filePath: Path,
        sourceTree: PBXSourceTree = .group,
        sourceRoot: Path,
        override: Bool = true,
        validatePresence: Bool = true
    ) throws -> PBXFileReference {
        let projectObjects = try objects()
        if validatePresence, !filePath.exists {
            throw XcodeprojEditingError.unexistingFile(filePath)
        }
        let groupPath = try fullPath(sourceRoot: sourceRoot)

        if override, let existingFileReference = try projectObjects.fileReferences.first(where: {
            // Optimization: compare lastComponent before fullPath compare
            guard let fileRefPath = $0.value.path else {
                return try filePath == $0.value.fullPath(sourceRoot: sourceRoot)
            }
            let fileRefLastPathComponent = fileRefPath.split(separator: "/").last!
            if filePath.lastComponent == fileRefLastPathComponent {
                return try filePath == $0.value.fullPath(sourceRoot: sourceRoot)
            }
            return false
        }) {
            if !childrenReferences.contains(existingFileReference.key) {
                existingFileReference.value.path = groupPath.flatMap { filePath.relative(to: $0) }?.string
                childrenReferences.append(existingFileReference.key)
            }
            return existingFileReference.value
        }

        let path: String?
        switch sourceTree {
        case .group:
            path = groupPath.map { filePath.relative(to: $0) }?.string
        case .sourceRoot:
            path = filePath.relative(to: sourceRoot).string
        case .absolute,
             .sdkRoot,
             .developerDir:
            path = filePath.string
        default:
            path = nil
        }
        let fileReference = PBXFileReference(
            sourceTree: sourceTree,
            name: filePath.lastComponent,
            explicitFileType: filePath.extension.flatMap(Xcode.filetype),
            lastKnownFileType: filePath.extension.flatMap(Xcode.filetype),
            path: path
        )
        projectObjects.add(object: fileReference)
        fileReference.parent = self
        if !childrenReferences.contains(fileReference.reference) {
            childrenReferences.append(fileReference.reference)
        }
        return fileReference
    }
}
