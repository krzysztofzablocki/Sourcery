import Foundation
import SwiftyJSON

final class BidderPosition: NSObject, JSONAbleType {
    let id: String
    let highestBid: Bid?
    let maxBidAmountCents: Int
    let processedAt: Date?

    init(id: String, highestBid: Bid?, maxBidAmountCents: Int, processedAt: Date?) {
        self.id = id
        self.highestBid = highestBid
        self.maxBidAmountCents = maxBidAmountCents
        self.processedAt = processedAt
    }

    static func fromJSON(_ source: [String: Any]) -> BidderPosition {
        let json = JSON(source)

        let id = json["id"].stringValue
        let maxBidAmount = json["max_bid_amount_cents"].intValue
        let processedAt = KioskDateFormatter.fromString(json["processed_at"].stringValue)

        var bid: Bid?
        if let bidDictionary = json["highest_bid"].object as? [String: AnyObject] {
            bid = Bid.fromJSON(bidDictionary)
        }

        return BidderPosition(id: id, highestBid: bid, maxBidAmountCents: maxBidAmount, processedAt: processedAt)
    }
}
