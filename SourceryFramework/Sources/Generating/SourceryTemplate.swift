import Foundation

public struct SourceryTemplate: Decodable {
    public struct Instance: Decodable {
        public enum Kind: String, Codable, Equatable {
            case stencil
            case ejs
        }

        public var content: String
        public var kind: Kind
    }

    enum CodingKeys: CodingKey {
        case instance
    }
    
    public let instance: Instance
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .instance)
        instance = try JSONDecoder().decode(Instance.self, from: data)
    }
}
