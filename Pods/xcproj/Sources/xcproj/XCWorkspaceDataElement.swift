import Foundation

public enum XCWorkspaceDataElement {

    public enum Error: Swift.Error {
        case unknownName(String)
    }

    case file(XCWorkspaceDataFileRef)
    case group(XCWorkspaceDataGroup)
}

extension XCWorkspaceDataElement: Equatable {

    public static func == (lhs: XCWorkspaceDataElement, rhs: XCWorkspaceDataElement) -> Bool {
        switch (lhs, rhs) {
        case let (.file(lhs), .file(rhs)):
            return lhs == rhs
        case let (.group(lhs), .group(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

