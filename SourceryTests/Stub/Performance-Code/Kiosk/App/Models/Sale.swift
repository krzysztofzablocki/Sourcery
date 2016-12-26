import UIKit
import SwiftyJSON

final class Sale: NSObject, JSONAbleType {
    dynamic let id: String
    dynamic let isAuction: Bool
    dynamic let startDate: Date
    dynamic let endDate: Date
    dynamic let name: String
    dynamic var artworkCount: Int
    dynamic let auctionState: String

    dynamic var buyersPremium: BuyersPremium?

    init(id: String, name: String, isAuction: Bool, startDate: Date, endDate: Date, artworkCount: Int, state: String) {
        self.id = id
        self.name = name
        self.isAuction = isAuction
        self.startDate = startDate
        self.endDate = endDate
        self.artworkCount = artworkCount
        self.auctionState = state
    }

    static func fromJSON(_ json: [String: Any]) -> Sale {
        let json = JSON(json)

        let id = json["id"].stringValue
        let isAuction = json["is_auction"].boolValue
        let startDate = KioskDateFormatter.fromString(json["start_at"].stringValue)!
        let endDate = KioskDateFormatter.fromString(json["end_at"].stringValue)!
        let name = json["name"].stringValue
        let artworkCount = json["eligible_sale_artworks_count"].intValue
        let state = json["auction_state"].stringValue

        let sale = Sale(id: id, name:name, isAuction: isAuction, startDate: startDate, endDate: endDate, artworkCount: artworkCount, state: state)

        if let buyersPremiumDict = json["buyers_premium"].object as? [String: AnyObject] {
            sale.buyersPremium = BuyersPremium.fromJSON(buyersPremiumDict)
        }

        return sale
    }

    func isActive(_ systemTime: SystemTime) -> Bool {
        let now = systemTime.date()
        return (now as NSDate).earlierDate(startDate) == startDate && (now as NSDate).laterDate(endDate) == endDate
    }
}
