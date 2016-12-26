import Foundation
import RxSwift
import Moya

protocol BidderNetworkModelType {
    var createdNewUser: Observable<Bool> { get }
    var bidDetails: BidDetails { get }

    func createOrGetBidder() -> Observable<AuthorizedNetworking>
}

class BidderNetworkModel: NSObject, BidderNetworkModelType {

    let bidDetails: BidDetails
    let provider: Networking

    var createdNewUser: Observable<Bool> {
        return self.bidDetails.newUser.hasBeenRegistered.asObservable()
    }

    init(provider: Networking, bidDetails: BidDetails) {
        self.provider = provider
        self.bidDetails = bidDetails
    }

    // MARK: - Main observable

    /// Returns an authorized provider
    func createOrGetBidder() -> Observable<AuthorizedNetworking> {
        return createOrUpdateUser()
            .flatMap { provider -> Observable<AuthorizedNetworking> in
                return self.createOrUpdateBidder(provider: provider).mapReplace(with: provider)
            }
            .flatMap { provider -> Observable<AuthorizedNetworking> in
                self.getMyPaddleNumber(provider: provider).mapReplace(with: provider)
            }
    }
}

private extension BidderNetworkModel {

    // MARK: - Chained observables

    func checkUserEmailExists(_ email: String) -> Observable<Bool> {
        let request = provider.request(.findExistingEmailRegistration(email: email))

        return request.map { response in
            return response.statusCode != 404
        }
    }

    func createOrUpdateUser() -> Observable<AuthorizedNetworking> {
        // observable to test for user existence (does a user exist with this email?)
        let bool = self.checkUserEmailExists(bidDetails.newUser.email.value ?? "")

        // If the user exists, update their info to the API, otherwise create a new user.
        return bool
            .flatMap { emailExists -> Observable<AuthorizedNetworking> in
                if emailExists {
                    return self.updateUser()
                } else {
                    return self.createNewUser()
                }
            }
            .flatMap { provider -> Observable<AuthorizedNetworking> in
                self.addCardToUser(provider: provider).mapReplace(with: provider) // After update/create observable finishes, add a CC to their account (if we've collected one)
            }
    }

    func createNewUser() -> Observable<AuthorizedNetworking> {
        let newUser = bidDetails.newUser
        let endpoint: ArtsyAPI = ArtsyAPI.createUser(email: newUser.email.value!, password: newUser.password.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnError { error in
                logger.log("Creating user failed.")
                logger.log("Error: \((error as NSError).localizedDescription). \n \((error as NSError).artsyServerError())")
        }.flatMap { _ -> Observable<AuthorizedNetworking> in
            self.bidDetails.authenticatedNetworking(provider: self.provider)
        }
    }

    func updateUser() -> Observable<AuthorizedNetworking> {
        let newUser = bidDetails.newUser
        let endpoint = ArtsyAuthenticatedAPI.updateMe(email: newUser.email.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")

        return bidDetails.authenticatedNetworking(provider: provider)
            .flatMap { (provider) -> Observable<AuthorizedNetworking> in
                provider.request(endpoint)
                    .mapJSON()
                    .logNext()
                    .mapReplace(with: provider)
            }
            .logServerError(message: "Updating user failed.")
    }

    func addCardToUser(provider: AuthorizedNetworking) -> Observable<Void> {
        // If the user was asked to swipe a card, we'd have stored the token. 
        // If the token is not there, then the user must already have one on file. So we can skip this step.
        guard let token = bidDetails.newUser.creditCardToken.value else {
            return .just(Void())
        }

        let swiped = bidDetails.newUser.swipedCreditCard
        let endpoint = ArtsyAuthenticatedAPI.registerCard(stripeToken: token, swiped: swiped)

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnCompleted { [weak self] in
                // Adding the credit card succeeded, so we should clear the newUser.creditCardToken so that we don't
                // inadvertently try to re-add their card token if they need to increase their bid.

                self?.bidDetails.newUser.creditCardToken.value = nil
            }
            .logServerError(message: "Adding Card to User failed")
    }

    // MARK: - Auction / Bidder observables

    func createOrUpdateBidder(provider: AuthorizedNetworking) -> Observable<Void> {
        let bool = self.checkForBidderOnAuction(auctionID: bidDetails.auctionID, provider: provider)

        return bool.flatMap { exists -> Observable<Void> in
            if exists {
                return .just(Void())
            } else {
                return self.register(toAuction: self.bidDetails.auctionID, provider: provider).then { [weak self] in self?.generateAPIN(provider: provider) }
            }
        }
    }

    func checkForBidderOnAuction(auctionID: String, provider: AuthorizedNetworking) -> Observable<Bool> {

        let endpoint = ArtsyAuthenticatedAPI.myBiddersForAuction(auctionID: auctionID)
        let request = provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(arrayOf: Bidder.self)

        return request.map { [weak self] bidders -> Bool in
            if let bidder = bidders.first {
                self?.bidDetails.bidderID.value = bidder.id
                self?.bidDetails.bidderPIN.value =  bidder.pin

                return true
            }
            return false

        }.logServerError(message: "Getting user bidders failed.")
    }

    func register(toAuction auctionID: String, provider: AuthorizedNetworking) -> Observable<Void> {
        let endpoint = ArtsyAuthenticatedAPI.registerToBid(auctionID: auctionID)
        let register = provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(object: Bidder.self)

        return
            register.doOnNext { [weak self] bidder in
                self?.bidDetails.bidderID.value = bidder.id
                self?.bidDetails.newUser.hasBeenRegistered.value = true
            }
            .logServerError(message: "Registering for Auction Failed.")
            .map(void)
    }

    func generateAPIN(provider: AuthorizedNetworking) -> Observable<Void> {
        let endpoint = ArtsyAuthenticatedAPI.createPINForBidder(bidderID: bidDetails.bidderID.value!)

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] json in
                let pin = (json as AnyObject)["pin"] as? String
                self?.bidDetails.bidderPIN.value = pin
            }
            .logServerError(message: "Generating a PIN for bidder has failed.")
            .map(void)
    }

    func getMyPaddleNumber(provider: AuthorizedNetworking) -> Observable<Void> {
        let endpoint = ArtsyAuthenticatedAPI.me
        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(object: User.self)
            .doOnNext { [weak self] user in
                self?.bidDetails.paddleNumber.value =  user.paddleNumber
            }
            .logServerError(message: "Getting Bidder ID failed.")
            .map(void)
    }
}
