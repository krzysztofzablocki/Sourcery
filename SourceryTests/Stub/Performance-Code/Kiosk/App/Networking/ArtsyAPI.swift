import Foundation
import RxSwift
import Moya
import Alamofire

protocol ArtsyAPIType {
    var addXAuth: Bool { get }
}

enum ArtsyAPI {
    case xApp
    case xAuth(email: String, password: String)
    case trustToken(number: String, auctionPIN: String)

    case systemTime
    case ping

    case artwork(id: String)
    case artist(id: String)

    case auctions
    case auctionListings(id: String, page: Int, pageSize: Int)
    case auctionInfo(auctionID: String)
    case auctionInfoForArtwork(auctionID: String, artworkID: String)
    case findBidderRegistration(auctionID: String, phone: String)
    case activeAuctions

    case createUser(email: String, password: String, phone: String, postCode: String, name: String)

    case bidderDetailsNotification(auctionID: String, identifier: String)

    case lostPasswordNotification(email: String)
    case findExistingEmailRegistration(email: String)
}

enum ArtsyAuthenticatedAPI {
    case myCreditCards
    case createPINForBidder(bidderID: String)
    case registerToBid(auctionID: String)
    case myBiddersForAuction(auctionID: String)
    case myBidPositionsForAuctionArtwork(auctionID: String, artworkID: String)
    case myBidPosition(id: String)
    case findMyBidderRegistration(auctionID: String)
    case placeABid(auctionID: String, artworkID: String, maxBidCents: String)

    case updateMe(email: String, phone: String, postCode: String, name: String)
    case registerCard(stripeToken: String, swiped: Bool)
    case me
}

extension ArtsyAPI : TargetType, ArtsyAPIType {
    public var task: Task {
        return .request
    }

     var path: String {
        switch self {

        case .xApp:
            return "/api/v1/xapp_token"

        case .xAuth:
            return "/oauth2/access_token"

        case .auctionInfo(let id):
            return "/api/v1/sale/\(id)"

        case .auctions:
            return "/api/v1/sales"

        case .auctionListings(let id, _, _):
            return "/api/v1/sale/\(id)/sale_artworks"

        case .auctionInfoForArtwork(let auctionID, let artworkID):
            return "/api/v1/sale/\(auctionID)/sale_artwork/\(artworkID)"

        case .systemTime:
            return "/api/v1/system/time"

        case .ping:
            return "/api/v1/system/ping"

        case .findBidderRegistration:
            return "/api/v1/bidder"

        case .activeAuctions:
            return "/api/v1/sales"

        case .createUser:
            return "/api/v1/user"

        case .artwork(let id):
            return "/api/v1/artwork/\(id)"

        case .artist(let id):
            return "/api/v1/artist/\(id)"

        case .trustToken:
            return "/api/v1/me/trust_token"

        case .bidderDetailsNotification:
            return "/api/v1/bidder/bidding_details_notification"

        case .lostPasswordNotification:
            return "/api/v1/users/send_reset_password_instructions"

        case .findExistingEmailRegistration:
            return "/api/v1/user"

        }
    }

    var base: String { return AppSetup.sharedState.useStaging ? "https://stagingapi.artsy.net" : "https://api.artsy.net" }
    var baseURL: URL { return URL(string: base)! }

    var parameters: [String: Any]? {
        switch self {

        case .xAuth(let email, let password):
            return [
                "client_id": APIKeys.sharedKeys.key as AnyObject? ?? "" as AnyObject,
                "client_secret": APIKeys.sharedKeys.secret as AnyObject? ?? "" as AnyObject,
                "email": email as AnyObject,
                "password":  password as AnyObject,
                "grant_type": "credentials" as AnyObject
            ]

        case .xApp:
            return ["client_id": APIKeys.sharedKeys.key as AnyObject? ?? "" as AnyObject,
                "client_secret": APIKeys.sharedKeys.secret as AnyObject? ?? "" as AnyObject]

        case .auctions:
            return ["is_auction": "true" as AnyObject]

        case .trustToken(let number, let auctionID):
            return ["number": number as AnyObject, "auction_pin": auctionID as AnyObject]

        case .createUser(let email, let password, let phone, let postCode, let name):
            return [
                "email": email as AnyObject, "password": password as AnyObject,
                "phone": phone as AnyObject, "name": name as AnyObject,
                "location": [ "postal_code": postCode ] as AnyObject
            ]

        case .bidderDetailsNotification(let auctionID, let identifier):
            return ["sale_id": auctionID as AnyObject, "identifier": identifier as AnyObject]

        case .lostPasswordNotification(let email):
            return ["email": email as AnyObject]

        case .findExistingEmailRegistration(let email):
            return ["email": email as AnyObject]

        case .findBidderRegistration(let auctionID, let phone):
            return ["sale_id": auctionID as AnyObject, "number": phone as AnyObject]

        case .auctionListings(_, let page, let pageSize):
            return ["size": pageSize as AnyObject, "page": page as AnyObject]

        case .activeAuctions:
            return ["is_auction": true as AnyObject, "live": true as AnyObject]

        default:
            return nil
        }
    }

    var method: Moya.Method {
        switch self {
        case .lostPasswordNotification,
        .createUser:
            return .post
        case .findExistingEmailRegistration:
            return .head
        case .bidderDetailsNotification:
            return .put
        default:
            return .get
        }
    }

    var sampleData: Data {
        switch self {

        case .xApp:
            return stubbedResponse("XApp")

        case .xAuth:
            return stubbedResponse("XAuth")

        case .trustToken:
            return stubbedResponse("XAuth")

        case .auctions:
            return stubbedResponse("Auctions")

        case .auctionListings:
            return stubbedResponse("AuctionListings")

        case .systemTime:
            return stubbedResponse("SystemTime")

        case .activeAuctions:
            return stubbedResponse("ActiveAuctions")

        case .createUser:
            return stubbedResponse("Me")

        case .artwork:
            return stubbedResponse("Artwork")

        case .artist:
            return stubbedResponse("Artist")

        case .auctionInfo:
            return stubbedResponse("AuctionInfo")

        // This API returns a 302, so stubbed response isn't valid
        case .findBidderRegistration:
            return stubbedResponse("Me")

        case .bidderDetailsNotification:
            return stubbedResponse("RegisterToBid")

        case .lostPasswordNotification:
            return stubbedResponse("ForgotPassword")

        case .findExistingEmailRegistration:
            return stubbedResponse("ForgotPassword")

        case .auctionInfoForArtwork:
            return stubbedResponse("AuctionInfoForArtwork")

        case .ping:
            return stubbedResponse("Ping")

        }
    }

    var addXAuth: Bool {
        switch self {
        case .xApp: return false
        case .xAuth: return false
        default: return true
        }
    }
}

extension ArtsyAuthenticatedAPI: TargetType, ArtsyAPIType {
    public var task: Task {
        return .request
    }

    var path: String {
        switch self {

        case .registerToBid:
            return "/api/v1/bidder"

        case .myCreditCards:
            return "/api/v1/me/credit_cards"

        case .createPINForBidder(let bidderID):
            return "/api/v1/bidder/\(bidderID)/pin"

        case .me:
            return "/api/v1/me"

        case .updateMe:
            return "/api/v1/me"

        case .myBiddersForAuction:
            return "/api/v1/me/bidders"

        case .myBidPositionsForAuctionArtwork:
            return "/api/v1/me/bidder_positions"

        case .myBidPosition(let id):
            return "/api/v1/me/bidder_position/\(id)"

        case .findMyBidderRegistration:
            return "/api/v1/me/bidders"

        case .placeABid:
            return "/api/v1/me/bidder_position"

        case .registerCard:
            return "/api/v1/me/credit_cards"
        }
    }

    var base: String { return AppSetup.sharedState.useStaging ? "https://stagingapi.artsy.net" : "https://api.artsy.net" }
    var baseURL: URL { return URL(string: base)! }

    var parameters: [String: Any]? {
        switch self {

        case .registerToBid(let auctionID):
            return ["sale_id": auctionID as AnyObject]

        case .myBiddersForAuction(let auctionID):
            return ["sale_id": auctionID as AnyObject]

        case .placeABid(let auctionID, let artworkID, let maxBidCents):
            return [
                "sale_id": auctionID as AnyObject,
                "artwork_id":  artworkID as AnyObject,
                "max_bid_amount_cents": maxBidCents as AnyObject
            ]

        case .findMyBidderRegistration(let auctionID):
            return ["sale_id": auctionID as AnyObject]

        case .updateMe(let email, let phone, let postCode, let name):
            return [
                "email": email as AnyObject, "phone": phone as AnyObject,
                "name": name as AnyObject, "location": [ "postal_code": postCode ]
            ]

        case .registerCard(let token, let swiped):
            return ["provider": "stripe" as AnyObject, "token": token as AnyObject, "created_by_trusted_client": swiped as AnyObject]

        case .myBidPositionsForAuctionArtwork(let auctionID, let artworkID):
            return ["sale_id": auctionID as AnyObject, "artwork_id": artworkID as AnyObject]

        default:
            return nil
        }
    }

    var method: Moya.Method {
        switch self {
        case .placeABid,
        .registerCard,
        .registerToBid,
        .createPINForBidder:
            return .post
        case .updateMe:
            return .put
        default:
            return .get
        }
    }

    var sampleData: Data {
        switch self {
        case .createPINForBidder:
            return stubbedResponse("CreatePINForBidder")

        case .myCreditCards:
            return stubbedResponse("MyCreditCards")

        case .registerToBid:
            return stubbedResponse("RegisterToBid")

        case .myBiddersForAuction:
            return stubbedResponse("MyBiddersForAuction")

        case .me:
            return stubbedResponse("Me")

        case .updateMe:
            return stubbedResponse("Me")

        case .placeABid:
            return stubbedResponse("CreateABid")

        case .findMyBidderRegistration:
            return stubbedResponse("FindMyBidderRegistration")

        case .registerCard:
            return stubbedResponse("RegisterCard")

        case .myBidPositionsForAuctionArtwork:
            return stubbedResponse("MyBidPositionsForAuctionArtwork")

        case .myBidPosition:
            return stubbedResponse("MyBidPosition")

        }
    }

    var addXAuth: Bool {
        return true
    }
}

// MARK: - Provider support

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }

    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
