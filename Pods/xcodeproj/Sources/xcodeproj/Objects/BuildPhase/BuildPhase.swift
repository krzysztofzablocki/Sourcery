import Foundation

/// Enum that encapsulates all kind of build phases available in Xcode.
///
/// - sources: sources.
/// - frameworks: frameworks.
/// - resources: resources.
/// - copyFiles: files.
/// - runScript: scripts.
/// - headers: headers.
/// - carbonResources: build legacy Carbon resources.
public enum BuildPhase: String {
    case sources = "Sources"
    case frameworks = "Frameworks"
    case resources = "Resources"
    case copyFiles = "CopyFiles"
    case runScript = "Run Script"
    case headers = "Headers"
    case carbonResources = "Rez"
}
