import Foundation

// MARK: - Decodable Extension

extension Decodable {

    /// Initialies the Decodable object with a JSON dictionary.
    ///
    /// - Parameter jsonDictionary: json dictionary.
    /// - Throws: throws an error if the initialization fails.
    init(jsonDictionary: [String: Any]) throws {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
    
}
