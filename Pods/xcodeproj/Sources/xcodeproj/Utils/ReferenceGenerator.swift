import Foundation

/// Generates the deterministic references of the project objects that have a temporary reference.
/// When objects are added to the project, those are added with a temporary reference that other
/// objects can refer to. Before saving the project, we make those references permanent giving them
/// a deterministic value that depends on the object itself and its ancestor.
protocol ReferenceGenerating: AnyObject {
    /// Generates the references of the objects of the given project.
    ///
    /// - Parameter proj: project whose objects references will be generated.
    /// - Parameter settings: settings to control the output references
    func generateReferences(proj: PBXProj) throws
}

/// Reference generator.
final class ReferenceGenerator: ReferenceGenerating {
    let outputSettings: PBXOutputSettings
    var references: Set<String> = []

    init(outputSettings: PBXOutputSettings) {
        self.outputSettings = outputSettings
    }

    /// Generates the references of the objects of the given project.
    ///
    /// - Parameter proj: project whose objects references will be generated.
    func generateReferences(proj: PBXProj) throws {
        guard let project: PBXProject = try proj.rootObjectReference?.getThrowingObject() else {
            return
        }

        // cache current reference values
        var references: Set<String> = []
        proj.objects.forEach { object in
            if !object.reference.temporary {
                references.insert(object.reference.value)
            }
        }
        self.references = references

        // Projects, targets, groups and file references.
        // Note: The references of those type of objects should be generated first.
        ///      We use them to generate the references of the objects that depend on them.
        ///      For instance, the reference of a build file, is generated from the reference of
        ///      the file it refers to.
        let identifiers = [project.name]
        generateProjectAndTargets(project: project, identifiers: identifiers)
        try generateGroupReferences(project.mainGroup, identifiers: identifiers)
        if let productsGroup: PBXGroup = project.productsGroup {
            try generateGroupReferences(productsGroup, identifiers: identifiers)
        }

        // Project references
        try project.projectReferences.forEach { objectReferenceDict in
            guard let projectReference = objectReferenceDict[Xcode.ProjectReference.projectReferenceKey]?.getObject() as? PBXFileReference,
                let productsGroup = objectReferenceDict[Xcode.ProjectReference.productGroupKey]?.getObject() as? PBXGroup else { return }
            try generateFileReference(projectReference, identifiers: identifiers)
            try generateGroupReferences(productsGroup, identifiers: identifiers + [projectReference.name ?? projectReference.path ?? ""])
        }

        // Targets
        let targets: [PBXTarget] = project.targets
        try targets.forEach { try generateTargetReferences($0, identifiers: identifiers) }

        /// Configuration list
        if let configurationList: XCConfigurationList = project.buildConfigurationListReference.getObject() {
            try generateConfigurationListReferences(configurationList, identifiers: identifiers)
        }
    }

    /// Generates the reference for the project and its target.
    ///
    /// - Parameters:
    ///   - project: project whose reference will be generated.
    ///   - identifiers: list of identifiers.
    private func generateProjectAndTargets(project: PBXProject,
                                           identifiers: [String]) {
        // Project
        fixReference(for: project, identifiers: identifiers)

        // Packages
        project.packages.forEach {
            var identifiers = identifiers
            identifiers.append($0.repositoryURL ?? $0.name ?? "")
            fixReference(for: $0, identifiers: identifiers)
        }

        // Targets
        let targets: [PBXTarget] = project.targetReferences.objects()
        targets.forEach { target in

            var identifiers = identifiers
            identifiers.append(target.name)

            // Packages
            target.packageProductDependencies.forEach {
                var identifiers = identifiers
                identifiers.append($0.productName)
                fixReference(for: $0, identifiers: identifiers)
            }

            fixReference(for: target, identifiers: identifiers)
        }
    }

    /// Generates the reference for a group object.
    ///
    /// - Parameters:
    ///   - group: group instance.
    ///   - identifiers: list of identifiers.
    private func generateGroupReferences(_ group: PBXGroup,
                                         identifiers: [String]) throws {
        var identifiers = identifiers
        if let groupName = group.fileName() {
            identifiers.append(groupName)
        }

        // Group
        fixReference(for: group, identifiers: identifiers)

        // Children
        try group.childrenReferences.forEach { child in
            guard let childFileElement: PBXFileElement = child.getObject() else { return }
            if let childGroup = childFileElement as? PBXGroup {
                try generateGroupReferences(childGroup, identifiers: identifiers)
            } else if let childFileReference = childFileElement as? PBXFileReference {
                try generateFileReference(childFileReference, identifiers: identifiers)
            } else if let childReferenceProxy = childFileElement as? PBXReferenceProxy {
                try generateReferenceProxyReference(childReferenceProxy, identifiers: identifiers)
            }
        }
    }

    /// Generates the reference for a file reference object.
    ///
    /// - Parameters:
    ///   - fileReference: file reference instance.
    ///   - identifiers: list of identifiers.
    private func generateFileReference(_ fileReference: PBXFileReference, identifiers: [String]) throws {
        var identifiers = identifiers
        if let groupName = fileReference.fileName() {
            identifiers.append(groupName)
        }

        fixReference(for: fileReference, identifiers: identifiers)
    }

    /// Generates the reference for a configuration list object.
    ///
    /// - Parameters:
    ///   - configurationList: configuration list instance.
    ///   - identifiers: list of identifiers.
    private func generateConfigurationListReferences(_ configurationList: XCConfigurationList,
                                                     identifiers: [String]) throws {
        fixReference(for: configurationList, identifiers: identifiers)

        let buildConfigurations: [XCBuildConfiguration] = configurationList.buildConfigurations

        buildConfigurations.forEach { configuration in
            if !configuration.reference.temporary { return }

            var identifiers = identifiers
            identifiers.append(configuration.name)

            fixReference(for: configuration, identifiers: identifiers)
        }
    }

    /// Generates the reference for a target object.
    ///
    /// - Parameters:
    ///   - target: target instance.
    ///   - identifiers: list of identifiers.
    private func generateTargetReferences(_ target: PBXTarget,
                                          identifiers: [String]) throws {
        var identifiers = identifiers
        identifiers.append(target.name)

        // Configuration list
        if let configurationList = target.buildConfigurationList {
            try generateConfigurationListReferences(configurationList,
                                                    identifiers: identifiers)
        }

        // Build phases
        let buildPhases: [PBXBuildPhase] = target.buildPhaseReferences.objects()
        try buildPhases.forEach { try generateBuildPhaseReferences($0,
                                                                   identifiers: identifiers) }

        // Build rules
        let buildRules: [PBXBuildRule] = target.buildRuleReferences.objects()
        try buildRules.forEach { try generateBuildRules($0, identifiers: identifiers) }

        // Dependencies
        let dependencies: [PBXTargetDependency] = target.dependencyReferences.objects()
        try dependencies.forEach { try generateTargetDependencyReferences($0, identifiers: identifiers) }
    }

    /// Generates the reference for a target dependency object.
    ///
    /// - Parameters:
    ///   - targetDependency: target dependency instance.
    ///   - identifiers: list of identifiers.
    private func generateTargetDependencyReferences(_ targetDependency: PBXTargetDependency,
                                                    identifiers: [String]) throws {
        var identifiers = identifiers

        // Target proxy
        if let targetProxyReference = targetDependency.targetProxyReference,
            targetProxyReference.temporary,
            let targetProxy = targetDependency.targetProxy,
            let remoteGlobalIDString = targetProxy.remoteGlobalID?.uuid {
            var identifiers = identifiers
            identifiers.append(remoteGlobalIDString)
            fixReference(for: targetProxy, identifiers: identifiers)
        }

        // Target dependency
        if targetDependency.reference.temporary {
            if let targetReference = targetDependency.targetReference?.value {
                identifiers.append(targetReference)
            }
            if let targetProxyReference = targetDependency.targetProxyReference?.value {
                identifiers.append(targetProxyReference)
            }
            fixReference(for: targetDependency, identifiers: identifiers)
        }
    }

    /// Generates the reference for a reference proxy object.
    ///
    /// - Parameters:
    ///   - referenceProxy: reference proxy instance.
    ///   - identifiers: list of identifiers.
    private func generateReferenceProxyReference(_ referenceProxy: PBXReferenceProxy,
                                                 identifiers: [String]) throws {
        var identifiers = identifiers

        if let path = referenceProxy.path {
            identifiers.append(path)
        }

        fixReference(for: referenceProxy, identifiers: identifiers)

        if let remote = referenceProxy.remote {
            try generateContainerItemProxyReference(remote, identifiers: identifiers)
        }
    }

    /// Generates the reference for a container item proxy object.
    ///
    /// - Parameters:
    ///   - containerItemProxy: ontainer item proxy instance.
    ///   - identifiers: list of identifiers.
    private func generateContainerItemProxyReference(_ containerItemProxy: PBXContainerItemProxy,
                                                     identifiers: [String]) throws {
        var identifiers = identifiers

        if let remoteInfo = containerItemProxy.remoteInfo {
            identifiers.append(remoteInfo)
        }
        fixReference(for: containerItemProxy, identifiers: identifiers)
    }

    /// Generates the reference for a build phase object.
    ///
    /// - Parameters:
    ///   - buildPhase: build phase instance.
    ///   - identifiers: list of identifiers.
    private func generateBuildPhaseReferences(_ buildPhase: PBXBuildPhase,
                                              identifiers: [String]) throws {
        var identifiers = identifiers
        if let name = buildPhase.name() {
            identifiers.append(name)
        }

        // Build phase
        fixReference(for: buildPhase, identifiers: identifiers)

        // Build files
        buildPhase.fileReferences?.forEach { buildFileReference in
            if !buildFileReference.temporary { return }

            guard let buildFile: PBXBuildFile = buildFileReference.getObject() else { return }

            var identifiers = identifiers

            if let fileReference = buildFile.fileReference,
                let fileReferenceObject: PBXObject = fileReference.getObject() {
                identifiers.append(fileReferenceObject.reference.value)
            }

            fixReference(for: buildFile, identifiers: identifiers)
        }
    }

    /// Generates the reference for a build rule object.
    ///
    /// - Parameters:
    ///   - buildRule: build phase instance.
    ///   - identifiers: list of identifiers.
    private func generateBuildRules(_ buildRule: PBXBuildRule,
                                    identifiers: [String]) throws {
        var identifiers = identifiers
        if let name = buildRule.name {
            identifiers.append(name)
        }

        // Build rule
        fixReference(for: buildRule, identifiers: identifiers)
    }
}

extension ReferenceGenerator {
    /// Given a list of identifiers, it generates a deterministic reference for a PBXObject.
    ///
    /// - Parameters:
    ///   - object: The object to generate a reference for
    ///   - identifiers: list of identifiers used to generate the reference of the object.
    func fixReference<T: PBXObject>(for object: T,
                                    identifiers: [String]) {
        if object.reference.temporary {
            var identifiers = identifiers
            if let context = object.context {
                identifiers.append(context)
            }
            let typeName = String(describing: type(of: object))

            // Get acronym to be used as prefix for the reference.
            // PBXFileReference is turned to FR.
            let acronym = typeName
                .replacingOccurrences(of: "PBX", with: "")
                .replacingOccurrences(of: "XC", with: "")
                .filter { String($0).lowercased() != String($0) }

            var reference = ""
            var counter = 0
            // Get the first reference that doesn't already exist
            repeat {
                counter += 1
                reference = generateReferenceFrom(acronym: acronym,
                                                  typeName: typeName,
                                                  identifiers: identifiers,
                                                  counter: counter)
            } while references.contains(reference)
            references.insert(reference)
            object.reference.fix(reference)
        }
    }

    private func generateReferenceFrom(acronym: String,
                                       typeName: String,
                                       identifiers: [String],
                                       counter: Int) -> String {
        let typeNameAndIdentifiers = ([typeName] + identifiers).joined(separator: "-")
        switch outputSettings.projReferenceFormat {
        case .withPrefixAndSuffix:
            let base = "\(acronym)_\(typeNameAndIdentifiers.md5.uppercased())"
            if counter > 1 {
                return "\(base)_\(counter)"
            } else {
                return base
            }
        case .xcode:
            let reference = "\(acronym)_\(typeNameAndIdentifiers)_\(counter)".md5.uppercased()
            return String(reference[...reference.index(reference.startIndex, offsetBy: 23)])
        }
    }
}
