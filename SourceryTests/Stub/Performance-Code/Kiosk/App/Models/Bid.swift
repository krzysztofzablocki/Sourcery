import Foundation
import SwiftyJSON

final class Bid: NSObject, JSONAbleType {
    let id: String
    let amountCents: Int

    init(id: String, amountCents: Int) {
        self.id = id
        self.amountCents = amountCents
    }

    static func fromJSON(_ json: [String: Any]) -> Bid {
        let json = JSON(json)

        let id = json["id"].stringValue
        let amount = json["amount_cents"].int
        return Bid(id: id, amountCents: amount!)
    }
}
