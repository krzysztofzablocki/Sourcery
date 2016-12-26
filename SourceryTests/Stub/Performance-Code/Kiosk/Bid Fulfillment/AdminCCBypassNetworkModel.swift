import Foundation
import RxSwift
import Moya

enum BypassResult {
    case requireCC
    case skipCCRequirement
}

protocol AdminCCBypassNetworkModelType {

    func checkForAdminCCBypass(_ saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResult>
}

class AdminCCBypassNetworkModel: AdminCCBypassNetworkModelType {

    /// Returns an Observable of (Bool, AuthorizedNetworking)
    /// The Bool represents if the Credit Card requirement should be waived.
    /// THe AuthorizedNetworking is the same instance that's passed in, which is a convenience for chaining observables.
    func checkForAdminCCBypass(_ saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResult> {

        return authorizedNetworking
            .request(ArtsyAuthenticatedAPI.findMyBidderRegistration(auctionID: saleID))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(arrayOf: Bidder.self)
            .map { bidders in
                return bidders.first
            }
            .map { bidder -> BypassResult in
                guard let bidder = bidder else { return .requireCC }

                switch bidder.createdByAdmin {
                case true: return .skipCCRequirement
                case false: return .requireCC
                }
            }
            .logError()
    }
}
