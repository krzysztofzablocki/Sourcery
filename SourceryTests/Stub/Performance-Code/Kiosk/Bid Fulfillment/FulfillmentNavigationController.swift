import UIKit
import Moya
import RxSwift

// We abstract this out so that we don't have network models, etc, aware of the view controller.
// This is a "source of truth" that should be referenced in lieu of many independent variables. 
protocol FulfillmentController: class {
    var bidDetails: BidDetails { get set }
    var auctionID: String! { get set }
}

class FulfillmentNavigationController: UINavigationController, FulfillmentController {

    // MARK: - FulfillmentController bits

    /// The the collection of details necessary to eventually create a bid
    lazy var bidDetails: BidDetails = {
        return BidDetails(saleArtwork:nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents:nil, auctionID: self.auctionID)
    }()
    var auctionID: String!
    var user: User!

    var provider: Networking!

    // MARK: - Everything else

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func reset() {
        let storage = HTTPCookieStorage.shared
        let cookies = storage.cookies
        cookies?.forEach { storage.deleteCookie($0) }
    }

    func updateUserCredentials(loggedInProvider: AuthorizedNetworking) -> Observable<Void> {
        let endpoint = ArtsyAuthenticatedAPI.me
        let request = loggedInProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapTo(object: User.self)

        return request
            .doOnNext { [weak self] fullUser in
                guard let me = self else { return }

                me.user = fullUser

                let newUser = me.bidDetails.newUser

                newUser.email.value = me.user.email
                newUser.phoneNumber.value = me.user.phoneNumber
                newUser.zipCode.value = me.user.location?.postalCode
                newUser.name.value = me.user.name
            }
            .logError(prefix: "error, the authentication for admin is likely wrong: ")
            .map(void)
    }
}

extension FulfillmentNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let viewController = viewController as? PlaceBidViewController else { return }

        viewController.provider = provider
    }
}
