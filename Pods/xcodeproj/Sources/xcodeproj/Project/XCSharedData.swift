import Foundation
import PathKit

public final class XCSharedData: Equatable {
    // MARK: - Attributes

    /// Shared data schemes.
    public var schemes: [XCScheme]

    /// Shared data breakpoints.
    public var breakpoints: XCBreakpointList?

    /// Workspace settings (represents the WorksapceSettings.xcsettings file).
    public var workspaceSettings: WorkspaceSettings?

    // MARK: - Init

    /// Initializes the shared data with its properties.
    ///
    /// - Parameters:
    ///   - schemes: Shared data schemes.
    ///   - breakpoints: Shared data breakpoints.
    ///   - workspaceSettings: Workspace settings (represents the WorksapceSettings.xcsettings file).
    public init(schemes: [XCScheme],
                breakpoints: XCBreakpointList? = nil,
                workspaceSettings: WorkspaceSettings? = nil) {
        self.schemes = schemes
        self.breakpoints = breakpoints
        self.workspaceSettings = workspaceSettings
    }

    /// Initializes the XCSharedData reading the content from the disk.
    ///
    /// - Parameter path: path where the .xcshareddata is.
    public init(path: Path) throws {
        if !path.exists {
            throw XCSharedDataError.notFound(path: path)
        }
        schemes = path.glob("xcschemes/*.xcscheme")
            .compactMap { try? XCScheme(path: $0) }
        breakpoints = try? XCBreakpointList(path: path + "xcdebugger/Breakpoints_v2.xcbkptlist")

        let workspaceSettingsPath = path + "WorkspaceSettings.xcsettings"
        if workspaceSettingsPath.exists {
            workspaceSettings = try WorkspaceSettings.at(path: workspaceSettingsPath)
        } else {
            workspaceSettings = nil
        }
    }

    // MARK: - Equatable

    public static func == (lhs: XCSharedData, rhs: XCSharedData) -> Bool {
        return lhs.schemes == rhs.schemes &&
            lhs.breakpoints == rhs.breakpoints &&
            lhs.workspaceSettings == rhs.workspaceSettings
    }
}
