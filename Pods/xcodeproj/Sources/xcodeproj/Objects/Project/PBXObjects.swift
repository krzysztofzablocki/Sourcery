import Foundation

// swiftlint:disable type_body_length
class PBXObjects: Equatable {
    // MARK: - Properties

    private let lock = NSRecursiveLock()

    private var _projects: [PBXObjectReference: PBXProject] = [:]
    var projects: [PBXObjectReference: PBXProject] {
        return lock.whileLocked { _projects }
    }

    private var _referenceProxies: [PBXObjectReference: PBXReferenceProxy] = [:]
    var referenceProxies: [PBXObjectReference: PBXReferenceProxy] {
        return lock.whileLocked { _referenceProxies }
    }

    // File elements
    private var _fileReferences: [PBXObjectReference: PBXFileReference] = [:]
    var fileReferences: [PBXObjectReference: PBXFileReference] {
        return lock.whileLocked { _fileReferences }
    }

    private var _versionGroups: [PBXObjectReference: XCVersionGroup] = [:]
    var versionGroups: [PBXObjectReference: XCVersionGroup] {
        return lock.whileLocked { _versionGroups }
    }

    private var _variantGroups: [PBXObjectReference: PBXVariantGroup] = [:]
    var variantGroups: [PBXObjectReference: PBXVariantGroup] {
        return lock.whileLocked { _variantGroups }
    }

    private var _groups: [PBXObjectReference: PBXGroup] = [:]
    var groups: [PBXObjectReference: PBXGroup] {
        return lock.whileLocked { _groups }
    }

    // Configuration
    private var _buildConfigurations: [PBXObjectReference: XCBuildConfiguration] = [:]
    var buildConfigurations: [PBXObjectReference: XCBuildConfiguration] {
        return lock.whileLocked { _buildConfigurations }
    }

    private var _configurationLists: [PBXObjectReference: XCConfigurationList] = [:]
    var configurationLists: [PBXObjectReference: XCConfigurationList] {
        return lock.whileLocked { _configurationLists }
    }

    // Targets
    private var _legacyTargets: [PBXObjectReference: PBXLegacyTarget] = [:]
    var legacyTargets: [PBXObjectReference: PBXLegacyTarget] {
        return lock.whileLocked { _legacyTargets }
    }

    private var _aggregateTargets: [PBXObjectReference: PBXAggregateTarget] = [:]
    var aggregateTargets: [PBXObjectReference: PBXAggregateTarget] {
        return lock.whileLocked { _aggregateTargets }
    }

    private var _nativeTargets: [PBXObjectReference: PBXNativeTarget] = [:]
    var nativeTargets: [PBXObjectReference: PBXNativeTarget] {
        return lock.whileLocked { _nativeTargets }
    }

    private var _targetDependencies: [PBXObjectReference: PBXTargetDependency] = [:]
    var targetDependencies: [PBXObjectReference: PBXTargetDependency] {
        return lock.whileLocked { _targetDependencies }
    }

    private var _containerItemProxies: [PBXObjectReference: PBXContainerItemProxy] = [:]
    var containerItemProxies: [PBXObjectReference: PBXContainerItemProxy] {
        return lock.whileLocked { _containerItemProxies }
    }

    private var _buildRules: [PBXObjectReference: PBXBuildRule] = [:]
    var buildRules: [PBXObjectReference: PBXBuildRule] {
        return lock.whileLocked { _buildRules }
    }

    // Build Phases
    private var _buildFiles: [PBXObjectReference: PBXBuildFile] = [:]
    var buildFiles: [PBXObjectReference: PBXBuildFile] {
        return lock.whileLocked { _buildFiles }
    }

    private var _copyFilesBuildPhases: [PBXObjectReference: PBXCopyFilesBuildPhase] = [:]
    var copyFilesBuildPhases: [PBXObjectReference: PBXCopyFilesBuildPhase] {
        return lock.whileLocked { _copyFilesBuildPhases }
    }

    private var _shellScriptBuildPhases: [PBXObjectReference: PBXShellScriptBuildPhase] = [:]
    var shellScriptBuildPhases: [PBXObjectReference: PBXShellScriptBuildPhase] {
        return lock.whileLocked { _shellScriptBuildPhases }
    }

    private var _resourcesBuildPhases: [PBXObjectReference: PBXResourcesBuildPhase] = [:]
    var resourcesBuildPhases: [PBXObjectReference: PBXResourcesBuildPhase] {
        return lock.whileLocked { _resourcesBuildPhases }
    }

    private var _frameworksBuildPhases: [PBXObjectReference: PBXFrameworksBuildPhase] = [:]
    var frameworksBuildPhases: [PBXObjectReference: PBXFrameworksBuildPhase] {
        return lock.whileLocked { _frameworksBuildPhases }
    }

    private var _headersBuildPhases: [PBXObjectReference: PBXHeadersBuildPhase] = [:]
    var headersBuildPhases: [PBXObjectReference: PBXHeadersBuildPhase] {
        return lock.whileLocked { _headersBuildPhases }
    }

    private var _sourcesBuildPhases: [PBXObjectReference: PBXSourcesBuildPhase] = [:]
    var sourcesBuildPhases: [PBXObjectReference: PBXSourcesBuildPhase] {
        return lock.whileLocked { _sourcesBuildPhases }
    }

    private var _carbonResourcesBuildPhases: [PBXObjectReference: PBXRezBuildPhase] = [:]
    var carbonResourcesBuildPhases: [PBXObjectReference: PBXRezBuildPhase] {
        return lock.whileLocked { _carbonResourcesBuildPhases }
    }

    private var _remoteSwiftPackageReferences: [PBXObjectReference: XCRemoteSwiftPackageReference] = [:]
    var remoteSwiftPackageReferences: [PBXObjectReference: XCRemoteSwiftPackageReference] {
        return lock.whileLocked { _remoteSwiftPackageReferences }
    }

    private var _swiftPackageProductDependencies: [PBXObjectReference: XCSwiftPackageProductDependency] = [:]
    var swiftPackageProductDependencies: [PBXObjectReference: XCSwiftPackageProductDependency] {
        return lock.whileLocked { _swiftPackageProductDependencies }
    }

    // XCSwiftPackageProductDependency

    /// Initializes the project objects container
    ///
    /// - Parameters:
    ///   - objects: project objects
    init(objects: [PBXObject] = []) {
        objects.forEach {
            _ = self.add(object: $0)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: PBXObjects, rhs: PBXObjects) -> Bool {
        return lhs.buildFiles == rhs.buildFiles &&
            lhs.legacyTargets == rhs.legacyTargets &&
            lhs.aggregateTargets == rhs.aggregateTargets &&
            lhs.containerItemProxies == rhs.containerItemProxies &&
            lhs.copyFilesBuildPhases == rhs.copyFilesBuildPhases &&
            lhs.groups == rhs.groups &&
            lhs.configurationLists == rhs.configurationLists &&
            lhs.buildConfigurations == rhs.buildConfigurations &&
            lhs.variantGroups == rhs.variantGroups &&
            lhs.targetDependencies == rhs.targetDependencies &&
            lhs.sourcesBuildPhases == rhs.sourcesBuildPhases &&
            lhs.shellScriptBuildPhases == rhs.shellScriptBuildPhases &&
            lhs.resourcesBuildPhases == rhs.resourcesBuildPhases &&
            lhs.frameworksBuildPhases == rhs.frameworksBuildPhases &&
            lhs.headersBuildPhases == rhs.headersBuildPhases &&
            lhs.nativeTargets == rhs.nativeTargets &&
            lhs.fileReferences == rhs.fileReferences &&
            lhs.projects == rhs.projects &&
            lhs.versionGroups == rhs.versionGroups &&
            lhs.referenceProxies == rhs.referenceProxies &&
            lhs.carbonResourcesBuildPhases == rhs.carbonResourcesBuildPhases &&
            lhs.buildRules == rhs.buildRules &&
            lhs.swiftPackageProductDependencies == rhs._swiftPackageProductDependencies &&
            lhs.remoteSwiftPackageReferences == rhs.remoteSwiftPackageReferences
    }

    // MARK: - Helpers

    /// Add a new object.
    ///
    /// - Parameters:
    ///   - object: object.
    func add(object: PBXObject) {
        lock.lock()
        defer {
            lock.unlock()
        }
        let objectReference: PBXObjectReference = object.reference
        objectReference.objects = self

        switch object {
        // subclasses of PBXGroup; must be tested before PBXGroup
        case let object as PBXVariantGroup: _variantGroups[objectReference] = object
        case let object as XCVersionGroup: _versionGroups[objectReference] = object

        // everything else
        case let object as PBXBuildFile: _buildFiles[objectReference] = object
        case let object as PBXAggregateTarget: _aggregateTargets[objectReference] = object
        case let object as PBXLegacyTarget: _legacyTargets[objectReference] = object
        case let object as PBXContainerItemProxy: _containerItemProxies[objectReference] = object
        case let object as PBXCopyFilesBuildPhase: _copyFilesBuildPhases[objectReference] = object
        case let object as PBXGroup: _groups[objectReference] = object
        case let object as XCConfigurationList: _configurationLists[objectReference] = object
        case let object as XCBuildConfiguration: _buildConfigurations[objectReference] = object
        case let object as PBXTargetDependency: _targetDependencies[objectReference] = object
        case let object as PBXSourcesBuildPhase: _sourcesBuildPhases[objectReference] = object
        case let object as PBXShellScriptBuildPhase: _shellScriptBuildPhases[objectReference] = object
        case let object as PBXResourcesBuildPhase: _resourcesBuildPhases[objectReference] = object
        case let object as PBXFrameworksBuildPhase: _frameworksBuildPhases[objectReference] = object
        case let object as PBXHeadersBuildPhase: _headersBuildPhases[objectReference] = object
        case let object as PBXNativeTarget: _nativeTargets[objectReference] = object
        case let object as PBXFileReference: _fileReferences[objectReference] = object
        case let object as PBXProject: _projects[objectReference] = object
        case let object as PBXReferenceProxy: _referenceProxies[objectReference] = object
        case let object as PBXRezBuildPhase: _carbonResourcesBuildPhases[objectReference] = object
        case let object as PBXBuildRule: _buildRules[objectReference] = object
        case let object as XCRemoteSwiftPackageReference: _remoteSwiftPackageReferences[objectReference] = object
        case let object as XCSwiftPackageProductDependency: _swiftPackageProductDependencies[objectReference] = object

        default: fatalError("Unhandled PBXObject type for \(object), this is likely a bug / todo")
        }
    }

    /// Deletes the object with the given reference.
    ///
    /// - Parameter reference: referenc of the object to be deleted.
    /// - Returns: the deleted object.
    // swiftlint:disable:next function_body_length Note: SwiftLint doesn't disable if @discardable and the function are on different lines.
    @discardableResult func delete(reference: PBXObjectReference) -> PBXObject? {
        lock.lock()
        defer { lock.unlock() }
        if let index = buildFiles.index(forKey: reference) {
            return _buildFiles.remove(at: index).value
        } else if let index = aggregateTargets.index(forKey: reference) {
            return _aggregateTargets.remove(at: index).value
        } else if let index = legacyTargets.index(forKey: reference) {
            return _legacyTargets.remove(at: index).value
        } else if let index = containerItemProxies.index(forKey: reference) {
            return _containerItemProxies.remove(at: index).value
        } else if let index = groups.index(forKey: reference) {
            return _groups.remove(at: index).value
        } else if let index = configurationLists.index(forKey: reference) {
            return _configurationLists.remove(at: index).value
        } else if let index = buildConfigurations.index(forKey: reference) {
            return _buildConfigurations.remove(at: index).value
        } else if let index = variantGroups.index(forKey: reference) {
            return _variantGroups.remove(at: index).value
        } else if let index = targetDependencies.index(forKey: reference) {
            return _targetDependencies.remove(at: index).value
        } else if let index = nativeTargets.index(forKey: reference) {
            return _nativeTargets.remove(at: index).value
        } else if let index = fileReferences.index(forKey: reference) {
            return _fileReferences.remove(at: index).value
        } else if let index = projects.index(forKey: reference) {
            return _projects.remove(at: index).value
        } else if let index = versionGroups.index(forKey: reference) {
            return _versionGroups.remove(at: index).value
        } else if let index = referenceProxies.index(forKey: reference) {
            return _referenceProxies.remove(at: index).value
        } else if let index = copyFilesBuildPhases.index(forKey: reference) {
            return _copyFilesBuildPhases.remove(at: index).value
        } else if let index = shellScriptBuildPhases.index(forKey: reference) {
            return _shellScriptBuildPhases.remove(at: index).value
        } else if let index = resourcesBuildPhases.index(forKey: reference) {
            return _resourcesBuildPhases.remove(at: index).value
        } else if let index = frameworksBuildPhases.index(forKey: reference) {
            return _frameworksBuildPhases.remove(at: index).value
        } else if let index = headersBuildPhases.index(forKey: reference) {
            return _headersBuildPhases.remove(at: index).value
        } else if let index = sourcesBuildPhases.index(forKey: reference) {
            return _sourcesBuildPhases.remove(at: index).value
        } else if let index = carbonResourcesBuildPhases.index(forKey: reference) {
            return _carbonResourcesBuildPhases.remove(at: index).value
        } else if let index = buildRules.index(forKey: reference) {
            return _buildRules.remove(at: index).value
        } else if let index = remoteSwiftPackageReferences.index(forKey: reference) {
            return _remoteSwiftPackageReferences.remove(at: index).value
        } else if let index = swiftPackageProductDependencies.index(forKey: reference) {
            return _swiftPackageProductDependencies.remove(at: index).value
        }
        return nil
    }

    /// It returns the object with the given reference.
    ///
    /// - Parameter reference: Xcode reference.
    /// - Returns: object.
    // swiftlint:disable:next function_body_length
    func get(reference: PBXObjectReference) -> PBXObject? {
        // This if-let expression is used because the equivalent chain of `??` separated lookups causes,
        // with Swift 4, this compiler error:
        //     Expression was too complex to be solved in reasonable time;
        //     consider breaking up the expression into distinct sub-expressions
        if let object = buildFiles[reference] {
            return object
        } else if let object = aggregateTargets[reference] {
            return object
        } else if let object = legacyTargets[reference] {
            return object
        } else if let object = containerItemProxies[reference] {
            return object
        } else if let object = groups[reference] {
            return object
        } else if let object = configurationLists[reference] {
            return object
        } else if let object = buildConfigurations[reference] {
            return object
        } else if let object = variantGroups[reference] {
            return object
        } else if let object = targetDependencies[reference] {
            return object
        } else if let object = nativeTargets[reference] {
            return object
        } else if let object = fileReferences[reference] {
            return object
        } else if let object = projects[reference] {
            return object
        } else if let object = versionGroups[reference] {
            return object
        } else if let object = referenceProxies[reference] {
            return object
        } else if let object = copyFilesBuildPhases[reference] {
            return object
        } else if let object = shellScriptBuildPhases[reference] {
            return object
        } else if let object = resourcesBuildPhases[reference] {
            return object
        } else if let object = frameworksBuildPhases[reference] {
            return object
        } else if let object = headersBuildPhases[reference] {
            return object
        } else if let object = sourcesBuildPhases[reference] {
            return object
        } else if let object = carbonResourcesBuildPhases[reference] {
            return object
        } else if let object = buildRules[reference] {
            return object
        } else if let object = remoteSwiftPackageReferences[reference] {
            return object
        } else if let object = swiftPackageProductDependencies[reference] {
            return object
        } else {
            return nil
        }
    }
}

// MARK: - Public

extension PBXObjects {
    /// Returns all the targets with the given name.
    ///
    /// - Parameters:
    ///   - name: target name.
    /// - Returns: targets with the given name.
    func targets(named name: String) -> [PBXTarget] {
        var targets: [PBXTarget] = []
        let filter = { (targets: [PBXObjectReference: PBXTarget]) -> [PBXTarget] in
            targets.values.filter { $0.name == name }
        }
        targets.append(contentsOf: filter(nativeTargets))
        targets.append(contentsOf: filter(legacyTargets))
        targets.append(contentsOf: filter(aggregateTargets))
        return targets
    }

    /// Invalidates all the objects references.
    func invalidateReferences() {
        forEach {
            $0.reference.invalidate()
        }
    }

    // MARK: - Computed Properties

    var buildPhases: [PBXObjectReference: PBXBuildPhase] {
        var phases: [PBXObjectReference: PBXBuildPhase] = [:]
        phases.merge(copyFilesBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(sourcesBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(shellScriptBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(resourcesBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(headersBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(carbonResourcesBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        phases.merge(frameworksBuildPhases as [PBXObjectReference: PBXBuildPhase], uniquingKeysWith: { first, _ in first })
        return phases
    }

    // This dictionary is used to quickly get a connection between the build phase and the build files of this phase.
    // This is used to decode build files. (we need the name of the build phase)
    // Otherwise, we would have to go through all the build phases for each file.
    var buildPhaseFile: [PBXObjectReference: PBXBuildPhaseFile] {
        let values: [[PBXBuildPhaseFile]] = buildPhases.values.map { buildPhase in
            let files = buildPhase.files
            let buildPhaseFile: [PBXBuildPhaseFile] = files?.compactMap { (file: PBXBuildFile) -> PBXBuildPhaseFile in
                PBXBuildPhaseFile(
                    buildFile: file,
                    buildPhase: buildPhase
                )
            } ?? []
            return buildPhaseFile
        }
        return Dictionary(values.flatMap { $0 }.map { ($0.buildFile.reference, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// Runs the given closure for each of the objects that are part of the project.
    ///
    /// - Parameter closure: closure to be run.
    func forEach(_ closure: (PBXObject) -> Void) {
        buildFiles.values.forEach(closure)
        legacyTargets.values.forEach(closure)
        aggregateTargets.values.forEach(closure)
        containerItemProxies.values.forEach(closure)
        groups.values.forEach(closure)
        configurationLists.values.forEach(closure)
        versionGroups.values.forEach(closure)
        buildConfigurations.values.forEach(closure)
        variantGroups.values.forEach(closure)
        targetDependencies.values.forEach(closure)
        nativeTargets.values.forEach(closure)
        fileReferences.values.forEach(closure)
        projects.values.forEach(closure)
        referenceProxies.values.forEach(closure)
        buildRules.values.forEach(closure)
        copyFilesBuildPhases.values.forEach(closure)
        shellScriptBuildPhases.values.forEach(closure)
        resourcesBuildPhases.values.forEach(closure)
        frameworksBuildPhases.values.forEach(closure)
        headersBuildPhases.values.forEach(closure)
        sourcesBuildPhases.values.forEach(closure)
        carbonResourcesBuildPhases.values.forEach(closure)
        remoteSwiftPackageReferences.values.forEach(closure)
        swiftPackageProductDependencies.values.forEach(closure)
    }
}
