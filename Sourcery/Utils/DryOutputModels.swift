import Foundation

struct DryOutputType: Codable {
    enum SubType: String, Codable {
        case allTemplates
        case template
        case path
        case range
    }

    let id: String?
    let subType: SubType

    static var allTemplates: DryOutputType {
        .init(id: nil, subType: .allTemplates)
    }
    static func template(_ path: String) -> DryOutputType {
        .init(id: path, subType: .template)
    }
    static func path(_ path: String) -> DryOutputType {
        .init(id: path, subType: .path)
    }
    static func range(_ range: NSRange, in file: String) -> DryOutputType {
        let startIndex = range.location
        let endIndex = range.location + range.length

        if startIndex == endIndex {
            return .init(id: "\(file):\(startIndex)", subType: .range)
        }

        return .init(id: "\(file):\(startIndex)-\(endIndex)", subType: .range)
    }
}

struct DryOutputValue: Codable {
    let type: DryOutputType
    let outputPath: String
    let value: String
}

struct DryOutputSuccess: Codable {
    let outputs: [DryOutputValue]
}

public struct DryOutputFailure: Codable {
    public let error: String
    public let log: [String]

    public init(error: String, log: [String]) {
        self.error = error
        self.log = log
    }
}
