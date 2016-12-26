import Foundation
import Moya

extension NSError {

    func artsyServerError() -> NSString {
        if let errorJSON = userInfo["data"] as? [String: AnyObject] {
            let error =  GenericError.fromJSON(errorJSON)
            return "\(error.message) - \(error.detail) + \(error.detail)" as NSString
        } else if let response = userInfo["data"] as? Response {
            let stringData = NSString(data: response.data, encoding: String.Encoding.utf8.rawValue)
            return "Status Code: \(response.statusCode), Data Length: \(response.data.count), String Data: \(stringData)" as NSString
        }

        return "\(userInfo)" as NSString
    }
}
