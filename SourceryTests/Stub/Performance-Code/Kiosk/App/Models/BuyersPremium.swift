import UIKit
import SwiftyJSON

final class BuyersPremium: NSObject, JSONAbleType {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    static func fromJSON(_ json: [String: Any]) -> BuyersPremium {
        let json = JSON(json)
        let id = json["id"].stringValue
        let name = json["name"].stringValue

        return BuyersPremium(id: id, name: name)
    }
}
