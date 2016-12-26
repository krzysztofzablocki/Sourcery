import UIKit
import SwiftyJSON

enum ReserveStatus: String {
    case ReserveNotMet = "reserve_not_met"
    case NoReserve = "no_reserve"
    case ReserveMet = "reserve_met"

    var reserveNotMet: Bool {
        return self == .ReserveNotMet
    }

    static func initOrDefault (_ rawValue: String?) -> ReserveStatus {
        return ReserveStatus(rawValue: rawValue ?? "") ?? .NoReserve
    }
}

struct SaleNumberFormatter {
    static let dollarFormatter = createDollarFormatter()
}

final class SaleArtwork: NSObject, JSONAbleType {

    let id: String
    let artwork: Artwork

    var auctionID: String?

    var saleHighestBid: Bid?
    dynamic var bidCount: NSNumber?

    var userBidderPosition: BidderPosition?
    var positions: [String]?

    var openingBidCents: NSNumber?
    var minimumNextBidCents: NSNumber?

    dynamic var highestBidCents: NSNumber?
    var estimateCents: Int?
    var lowEstimateCents: Int?
    var highEstimateCents: Int?

    dynamic var reserveStatus: String?
    dynamic var lotNumber: NSNumber?

    init(id: String, artwork: Artwork) {
        self.id = id
        self.artwork = artwork
    }

    lazy var viewModel: SaleArtworkViewModel = {
        return SaleArtworkViewModel(saleArtwork: self)
    }()

    static func fromJSON(_ json: [String: Any]) -> SaleArtwork {
        let json = JSON(json)
        let id = json["id"].stringValue
        let artworkDict = json["artwork"].object as! [String: AnyObject]
        let artwork = Artwork.fromJSON(artworkDict)

        let saleArtwork = SaleArtwork(id: id, artwork: artwork) as SaleArtwork

        if let highestBidDict = json["highest_bid"].object as? [String: AnyObject] {
            saleArtwork.saleHighestBid = Bid.fromJSON(highestBidDict)
        }

        saleArtwork.auctionID = json["sale_id"].string
        saleArtwork.openingBidCents = json["opening_bid_cents"].int as NSNumber?
        saleArtwork.minimumNextBidCents = json["minimum_next_bid_cents"].int as NSNumber?

        saleArtwork.highestBidCents = json["highest_bid_amount_cents"].int as NSNumber?
        saleArtwork.estimateCents = json["estimate_cents"].int
        saleArtwork.lowEstimateCents = json["low_estimate_cents"].int
        saleArtwork.highEstimateCents = json["high_estimate_cents"].int
        saleArtwork.bidCount = json["bidder_positions_count"].int as NSNumber?
        saleArtwork.reserveStatus = json["reserve_status"].string
        saleArtwork.lotNumber = json["lot_number"].int as NSNumber?

        return saleArtwork
    }

    func updateWithValues(_ newSaleArtwork: SaleArtwork) {
        saleHighestBid = newSaleArtwork.saleHighestBid
        auctionID = newSaleArtwork.auctionID
        openingBidCents = newSaleArtwork.openingBidCents
        minimumNextBidCents = newSaleArtwork.minimumNextBidCents
        highestBidCents = newSaleArtwork.highestBidCents
        estimateCents = newSaleArtwork.estimateCents
        lowEstimateCents = newSaleArtwork.lowEstimateCents
        highEstimateCents = newSaleArtwork.highEstimateCents
        bidCount = newSaleArtwork.bidCount
        reserveStatus = newSaleArtwork.reserveStatus
        lotNumber = newSaleArtwork.lotNumber ?? lotNumber

        artwork.updateWithValues(newSaleArtwork.artwork)
    }
}

func createDollarFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.currency

    // This is always dollars, so let's make sure that's how it shows up
    // regardless of locale.

    formatter.currencyGroupingSeparator = ","
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter
}

func ==(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return lhs.id == rhs.id
}
