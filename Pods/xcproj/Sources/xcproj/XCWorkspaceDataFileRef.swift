import Foundation

final public class XCWorkspaceDataFileRef {

    public var location: XCWorkspaceDataElementLocationType

    public init(location: XCWorkspaceDataElementLocationType) {
        self.location = location
    }
}

extension XCWorkspaceDataFileRef: Equatable {

    public static func == (lhs: XCWorkspaceDataFileRef, rhs: XCWorkspaceDataFileRef) -> Bool {
        return lhs.location == rhs.location
    }
}
