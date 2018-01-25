import Foundation

final public class XCWorkspaceDataGroup {

    public var location: XCWorkspaceDataElementLocationType
    public var name: String?
    public var children: [XCWorkspaceDataElement]

    public init(location: XCWorkspaceDataElementLocationType, name: String?, children: [XCWorkspaceDataElement]) {
        self.location = location
        self.name = name
        self.children = children
    }
}

extension XCWorkspaceDataGroup: Equatable {

    public static func == (lhs: XCWorkspaceDataGroup, rhs: XCWorkspaceDataGroup) -> Bool {
        return lhs.location == rhs.location &&
            lhs.name == rhs.name &&
            lhs.children == rhs.children
    }
}
