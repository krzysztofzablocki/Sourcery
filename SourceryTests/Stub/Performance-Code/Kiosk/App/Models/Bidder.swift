import UIKit
import SwiftyJSON

final class Bidder: NSObject, JSONAbleType {
    let id: String
    let saleID: String
    let createdByAdmin: Bool
    var pin: String?

    init(id: String, saleID: String, createdByAdmin: Bool, pin: String?) {
        self.id = id
        self.saleID = saleID
        self.createdByAdmin = createdByAdmin
        self.pin = pin
    }

    static func fromJSON(_ json: [String: Any]) -> Bidder {
        let json = JSON(json)

        let id = json["id"].stringValue
        let saleID = json["sale"]["id"].stringValue
        let createdByAdmin = json["created_by_admin"].bool ?? false
        let pin = json["pin"].stringValue
        return Bidder(id: id, saleID: saleID, createdByAdmin: createdByAdmin, pin: pin)
    }
}
