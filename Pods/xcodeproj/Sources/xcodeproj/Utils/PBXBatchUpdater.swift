import Foundation
import PathKit

// This is a helper class for quickly adding a large number of files.
// It is forbidden to add a file to a group one by one using the PBXGroup method addFile(...) while you are working with this class.
public final class PBXBatchUpdater {
    private let objects: PBXObjects
    private let sourceRoot: Path
    private var references: [Path: PBXObjectReference]?
    private var groups: [Path: PBXGroup]?

    init(objects: PBXObjects, sourceRoot: Path) {
        self.objects = objects
        self.sourceRoot = sourceRoot
    }

    /// Adds file at the give path to the project or returns existing file and its reference.
    ///
    /// - Parameters:
    ///   - project: project for update
    ///   - filePath: path to the file.
    ///   - sourceTree: file sourceTree, default is `.group`
    /// - Returns: new or existing file and its reference.
    @discardableResult
    public func addFile(
        to project: PBXProject,
        at filePath: Path,
        sourceTree: PBXSourceTree = .group
    )
        throws -> PBXFileReference {
        let (group, groupPath) = try groupAndGroupPathForFile(
            at: filePath,
            project: project
        )
        return try addFile(
            to: group,
            groupPath: groupPath,
            filePath: filePath,
            sourceTree: sourceTree
        )
    }

    /// Adds file at the give path to the project or returns existing file and its reference.
    ///
    /// - Parameters:
    ///   - group: parent group
    ///   - fileName: name of the file.
    ///   - sourceTree: file sourceTree, default is `.group`
    /// - Returns: new or existing file and its reference.
    @discardableResult
    public func addFile(
        to group: PBXGroup,
        fileName: String,
        sourceTree: PBXSourceTree = .group
    )
        throws -> PBXFileReference {
        let groupPath = try group.fullPath(sourceRoot: sourceRoot)!
        let filePath = groupPath + Path(fileName)
        return try addFile(
            to: group,
            groupPath: groupPath,
            filePath: filePath,
            sourceTree: sourceTree
        )
    }

    private func addFile(
        to group: PBXGroup,
        groupPath: Path,
        filePath: Path,
        sourceTree: PBXSourceTree = .group
    )
        throws -> PBXFileReference {
        if let existing = try existingFileReference(at: filePath, in: group) {
            return existing
        }

        let path: String?
        switch sourceTree {
        case .group:
            path = filePath.relative(to: groupPath).string
        case .sourceRoot:
            path = filePath.relative(to: sourceRoot).string
        case .absolute:
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
        objects.add(object: fileReference)
        fileReference.parent = group
        references?[filePath] = fileReference.reference
        if !group.childrenReferences.contains(fileReference.reference) {
            group.childrenReferences.append(fileReference.reference)
        }
        return fileReference
    }

    private func existingFileReference(at filePath: Path, in group: PBXGroup) throws -> PBXFileReference? {
        let objectReferences = try lazilyInstantiateObjectReferences()
        if let existingObjectReference = objectReferences[filePath],
            let existingFileReference = objects.fileReferences[existingObjectReference] {
            if !group.childrenReferences.contains(existingObjectReference) {
                group.childrenReferences.append(existingObjectReference)
            }
            return existingFileReference
        }
        return nil
    }

    private func groupAndGroupPathForFile(at path: Path, project: PBXProject) throws -> (PBXGroup, Path) {
        let groupPath = path.parent()
        if let fileParentGroup = try lazilyInstantiateGroups()[groupPath] {
            return (fileParentGroup, groupPath)
        }
        var components = groupPath.components
        let componentsCount = components.count - 1
        for componentIndex in (0 ... componentsCount).reversed() {
            let currentPathComponents = components[0 ... componentIndex]
            let currentPath = Path(components: currentPathComponents)
            if let rootGroup = try lazilyInstantiateGroups()[currentPath] {
                let subgroupNames = Array(
                    components[componentIndex + 1 ... componentsCount]
                )
                let fileParentGroup = try createChildGroups(
                    in: rootGroup,
                    groupPath: currentPath,
                    with: subgroupNames
                )
                let fileParentGroupPath = currentPath + Path(components: subgroupNames)
                return (fileParentGroup, fileParentGroupPath)
            }
        }
        let mainGroup = project.mainGroup!
        let mainGroupFullPath = try mainGroup.fullPath(sourceRoot: sourceRoot)!
        let fileParentGroup = try createChildGroups(
            in: mainGroup,
            groupPath: mainGroupFullPath,
            with: groupPath.components
        )

        let fileParentGroupPath = mainGroupFullPath + Path(components: groupPath.components)
        return (fileParentGroup, fileParentGroupPath)
    }

    func createChildGroups(
        in group: PBXGroup,
        groupPath: Path,
        with names: [String]
    )
        throws -> PBXGroup {
        var parent = group
        for (index, name) in names.enumerated() {
            let path = groupPath + Path(components: names[0 ... index])
            parent = try parent.addGroup(named: name).last!
            groups?[path] = parent
        }
        return parent
    }

    private func lazilyInstantiateObjectReferences()
        throws -> [Path: PBXObjectReference] {
        let objectReferences: [Path: PBXObjectReference]
        if let references = self.references {
            objectReferences = references
        } else {
            objectReferences = Dictionary(uniqueKeysWithValues:
                try objects.fileReferences.compactMap {
                    let fullPath = try $0.value.fullPath(sourceRoot: sourceRoot)!
                    return (fullPath, $0.key)
            })
            references = objectReferences
        }
        return objectReferences
    }

    private func lazilyInstantiateGroups() throws -> [Path: PBXGroup] {
        let unwrappedGroups: [Path: PBXGroup]
        if let groups = self.groups {
            unwrappedGroups = groups
        } else {
            unwrappedGroups = Dictionary(uniqueKeysWithValues:
                try objects.groups.compactMap {
                    let fullPath = try $0.value.fullPath(sourceRoot: sourceRoot)!
                    return (fullPath, $0.value)
            })
            groups = unwrappedGroups
        }
        return unwrappedGroups
    }
}
