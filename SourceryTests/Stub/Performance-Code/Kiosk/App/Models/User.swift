import Foundation
import SwiftyJSON

final class User: NSObject, JSONAbleType {

    dynamic let id: String
    dynamic let email: String
    dynamic let name: String
    dynamic let paddleNumber: String
    dynamic let phoneNumber: String
    dynamic var bidder: Bidder?
    dynamic var location: Location?

    init(id: String, email: String, name: String, paddleNumber: String, phoneNumber: String, location: Location?) {
        self.id = id
        self.name = name
        self.paddleNumber = paddleNumber
        self.email = email
        self.phoneNumber = phoneNumber
        self.location = location
    }

    static func fromJSON(_ json: [String: Any]) -> User {
        let json = JSON(json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let email = json["email"].stringValue
        let paddleNumber = json["paddle_number"].stringValue
        let phoneNumber = json["phone"].stringValue

        var location: Location?
        if let bidDictionary = json["location"].object as? [String: AnyObject] {
            location = Location.fromJSON(bidDictionary)
        }

        return User(id: id, email: email, name: name, paddleNumber: paddleNumber, phoneNumber: phoneNumber, location:location)
    }
}
