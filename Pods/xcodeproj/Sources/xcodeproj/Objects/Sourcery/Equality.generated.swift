// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension PBXAggregateTarget {
    /// :nodoc:
    func isEqual(to rhs: PBXAggregateTarget) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXBuildFile {
    /// :nodoc:
    func isEqual(to rhs: PBXBuildFile) -> Bool {
        if fileReference != rhs.fileReference { return false }
        if productReference != rhs.productReference { return false }
        if !NSDictionary(dictionary: settings ?? [:]).isEqual(to: rhs.settings ?? [:]) { return false }
        if platformFilter != rhs.platformFilter { return false }
        if buildPhase != rhs.buildPhase { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXBuildPhase) -> Bool {
        if buildActionMask != rhs.buildActionMask { return false }
        if fileReferences != rhs.fileReferences { return false }
        if inputFileListPaths != rhs.inputFileListPaths { return false }
        if outputFileListPaths != rhs.outputFileListPaths { return false }
        if runOnlyForDeploymentPostprocessing != rhs.runOnlyForDeploymentPostprocessing { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXBuildRule {
    /// :nodoc:
    func isEqual(to rhs: PBXBuildRule) -> Bool {
        if compilerSpec != rhs.compilerSpec { return false }
        if filePatterns != rhs.filePatterns { return false }
        if fileType != rhs.fileType { return false }
        if isEditable != rhs.isEditable { return false }
        if name != rhs.name { return false }
        if outputFiles != rhs.outputFiles { return false }
        if inputFiles != rhs.inputFiles { return false }
        if outputFilesCompilerFlags != rhs.outputFilesCompilerFlags { return false }
        if script != rhs.script { return false }
        if runOncePerArchitecture != rhs.runOncePerArchitecture { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXContainerItem {
    /// :nodoc:
    func isEqual(to rhs: PBXContainerItem) -> Bool {
        if comments != rhs.comments { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXContainerItemProxy {
    /// :nodoc:
    func isEqual(to rhs: PBXContainerItemProxy) -> Bool {
        if containerPortalReference != rhs.containerPortalReference { return false }
        if proxyType != rhs.proxyType { return false }
        if remoteGlobalIDReference != rhs.remoteGlobalIDReference { return false }
        if remoteInfo != rhs.remoteInfo { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXCopyFilesBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXCopyFilesBuildPhase) -> Bool {
        if dstPath != rhs.dstPath { return false }
        if dstSubfolderSpec != rhs.dstSubfolderSpec { return false }
        if name != rhs.name { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXFileElement {
    /// :nodoc:
    func isEqual(to rhs: PBXFileElement) -> Bool {
        if sourceTree != rhs.sourceTree { return false }
        if path != rhs.path { return false }
        if name != rhs.name { return false }
        if includeInIndex != rhs.includeInIndex { return false }
        if usesTabs != rhs.usesTabs { return false }
        if indentWidth != rhs.indentWidth { return false }
        if tabWidth != rhs.tabWidth { return false }
        if wrapsLines != rhs.wrapsLines { return false }
        if parent != rhs.parent { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXFileReference {
    /// :nodoc:
    func isEqual(to rhs: PBXFileReference) -> Bool {
        if fileEncoding != rhs.fileEncoding { return false }
        if explicitFileType != rhs.explicitFileType { return false }
        if lastKnownFileType != rhs.lastKnownFileType { return false }
        if lineEnding != rhs.lineEnding { return false }
        if languageSpecificationIdentifier != rhs.languageSpecificationIdentifier { return false }
        if xcLanguageSpecificationIdentifier != rhs.xcLanguageSpecificationIdentifier { return false }
        if plistStructureDefinitionIdentifier != rhs.plistStructureDefinitionIdentifier { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXFrameworksBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXFrameworksBuildPhase) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXGroup {
    /// :nodoc:
    func isEqual(to rhs: PBXGroup) -> Bool {
        if childrenReferences != rhs.childrenReferences { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXHeadersBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXHeadersBuildPhase) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXLegacyTarget {
    /// :nodoc:
    func isEqual(to rhs: PBXLegacyTarget) -> Bool {
        if buildToolPath != rhs.buildToolPath { return false }
        if buildArgumentsString != rhs.buildArgumentsString { return false }
        if passBuildSettingsInEnvironment != rhs.passBuildSettingsInEnvironment { return false }
        if buildWorkingDirectory != rhs.buildWorkingDirectory { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXNativeTarget {
    /// :nodoc:
    func isEqual(to rhs: PBXNativeTarget) -> Bool {
        if productInstallPath != rhs.productInstallPath { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXProject {
    /// :nodoc:
    func isEqual(to rhs: PBXProject) -> Bool {
        if name != rhs.name { return false }
        if buildConfigurationListReference != rhs.buildConfigurationListReference { return false }
        if compatibilityVersion != rhs.compatibilityVersion { return false }
        if developmentRegion != rhs.developmentRegion { return false }
        if hasScannedForEncodings != rhs.hasScannedForEncodings { return false }
        if knownRegions != rhs.knownRegions { return false }
        if mainGroupReference != rhs.mainGroupReference { return false }
        if productsGroupReference != rhs.productsGroupReference { return false }
        if projectDirPath != rhs.projectDirPath { return false }
        if projectReferences != rhs.projectReferences { return false }
        if projectRoots != rhs.projectRoots { return false }
        if targetReferences != rhs.targetReferences { return false }
        if !NSDictionary(dictionary: attributes).isEqual(to: rhs.attributes) { return false }
        if !NSDictionary(dictionary: targetAttributeReferences).isEqual(to: rhs.targetAttributeReferences) { return false }
        if packageReferences != rhs.packageReferences { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXReferenceProxy {
    /// :nodoc:
    func isEqual(to rhs: PBXReferenceProxy) -> Bool {
        if fileType != rhs.fileType { return false }
        if remoteReference != rhs.remoteReference { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXResourcesBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXResourcesBuildPhase) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXRezBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXRezBuildPhase) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXShellScriptBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXShellScriptBuildPhase) -> Bool {
        if name != rhs.name { return false }
        if inputPaths != rhs.inputPaths { return false }
        if outputPaths != rhs.outputPaths { return false }
        if shellPath != rhs.shellPath { return false }
        if shellScript != rhs.shellScript { return false }
        if showEnvVarsInLog != rhs.showEnvVarsInLog { return false }
        if alwaysOutOfDate != rhs.alwaysOutOfDate { return false }
        if dependencyFile != rhs.dependencyFile { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXSourcesBuildPhase {
    /// :nodoc:
    func isEqual(to rhs: PBXSourcesBuildPhase) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension PBXTarget {
    /// :nodoc:
    func isEqual(to rhs: PBXTarget) -> Bool {
        if buildConfigurationListReference != rhs.buildConfigurationListReference { return false }
        if buildPhaseReferences != rhs.buildPhaseReferences { return false }
        if buildRuleReferences != rhs.buildRuleReferences { return false }
        if dependencyReferences != rhs.dependencyReferences { return false }
        if name != rhs.name { return false }
        if productName != rhs.productName { return false }
        if productReference != rhs.productReference { return false }
        if packageProductDependencyReferences != rhs.packageProductDependencyReferences { return false }
        if productType != rhs.productType { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXTargetDependency {
    /// :nodoc:
    func isEqual(to rhs: PBXTargetDependency) -> Bool {
        if name != rhs.name { return false }
        if targetReference != rhs.targetReference { return false }
        if targetProxyReference != rhs.targetProxyReference { return false }
        if productReference != rhs.productReference { return false }
        if platformFilter != rhs.platformFilter { return false }
        return super.isEqual(to: rhs)
    }
}

extension PBXVariantGroup {
    /// :nodoc:
    func isEqual(to rhs: PBXVariantGroup) -> Bool {
        return super.isEqual(to: rhs)
    }
}

extension XCBuildConfiguration {
    /// :nodoc:
    func isEqual(to rhs: XCBuildConfiguration) -> Bool {
        if baseConfigurationReference != rhs.baseConfigurationReference { return false }
        if !NSDictionary(dictionary: buildSettings).isEqual(to: rhs.buildSettings) { return false }
        if name != rhs.name { return false }
        return super.isEqual(to: rhs)
    }
}

extension XCConfigurationList {
    /// :nodoc:
    func isEqual(to rhs: XCConfigurationList) -> Bool {
        if buildConfigurationReferences != rhs.buildConfigurationReferences { return false }
        if defaultConfigurationIsVisible != rhs.defaultConfigurationIsVisible { return false }
        if defaultConfigurationName != rhs.defaultConfigurationName { return false }
        return super.isEqual(to: rhs)
    }
}

extension XCRemoteSwiftPackageReference {
    /// :nodoc:
    func isEqual(to rhs: XCRemoteSwiftPackageReference) -> Bool {
        if repositoryURL != rhs.repositoryURL { return false }
        if versionRequirement != rhs.versionRequirement { return false }
        return super.isEqual(to: rhs)
    }
}

extension XCSwiftPackageProductDependency {
    /// :nodoc:
    func isEqual(to rhs: XCSwiftPackageProductDependency) -> Bool {
        if productName != rhs.productName { return false }
        if packageReference != rhs.packageReference { return false }
        return super.isEqual(to: rhs)
    }
}

extension XCVersionGroup {
    /// :nodoc:
    func isEqual(to rhs: XCVersionGroup) -> Bool {
        if currentVersionReference != rhs.currentVersionReference { return false }
        if versionGroupType != rhs.versionGroupType { return false }
        return super.isEqual(to: rhs)
    }
}
