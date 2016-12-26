import Foundation
import ARAnalytics
import RxSwift

protocol LoadingViewModelType {

    var createdNewBidder: Variable<Bool> { get }
    var bidIsResolved: Variable<Bool> { get }
    var isHighestBidder: Variable<Bool> { get }
    var reserveNotMet: Variable<Bool> { get }
    var bidDetails: BidDetails { get }

    func performActions() -> Observable<Void>
}

/// Encapsulates activities of the LoadingViewController.
class LoadingViewModel: NSObject, LoadingViewModelType {
    let placingBid: Bool
    let bidderNetworkModel: BidderNetworkModelType

    lazy var placeBidNetworkModel: PlaceBidNetworkModelType = {
        return PlaceBidNetworkModel(bidDetails: self.bidderNetworkModel.bidDetails)
    }()
    lazy var bidCheckingModel: BidCheckingNetworkModelType = {
        return BidCheckingNetworkModel(provider: self.provider, bidDetails: self.bidderNetworkModel.bidDetails)
    }()

    let provider: Networking
    let createdNewBidder = Variable(false)
    let bidIsResolved = Variable(false)
    let isHighestBidder = Variable(false)
    let reserveNotMet = Variable(false)

    var bidDetails: BidDetails {
        return bidderNetworkModel.bidDetails
    }

    init(provider: Networking, bidNetworkModel: BidderNetworkModelType, placingBid: Bool, actionsComplete: Observable<Void>) {
        self.provider = provider
        self.bidderNetworkModel = bidNetworkModel
        self.placingBid = placingBid

        super.init()

        // Set up bindings.
        [
            (bidderNetworkModel.createdNewUser, createdNewBidder),
            (bidCheckingModel.bidIsResolved.asObservable(), bidIsResolved),
            (bidCheckingModel.isHighestBidder.asObservable(), isHighestBidder),
            (bidCheckingModel.reserveNotMet.asObservable(), reserveNotMet)
        ].forEach { pair in
            pair.0
                .takeUntil(actionsComplete)
                .bindTo(pair.1)
                .addDisposableTo(rx_disposeBag)
        }
    }

    /// Encapsulates essential activities of the LoadingViewController, including:
    /// - Registering new users
    /// - Placing bids for users
    /// - Polling for bid results
    func performActions() -> Observable<Void> {
        return bidderNetworkModel
            .createOrGetBidder()
            .flatMap { [weak self] provider -> Observable<(String, AuthorizedNetworking)> in
                guard let me = self else { return .empty() }
                guard me.placingBid else {
                    ARAnalytics.event("Registered New User Only")
                    // Skipping all further actions, since we're not placing a bid.
                    return .empty()
                }

                ARAnalytics.event("Started Placing Bid", withProperties: ["id": me.bidDetails.saleArtwork?.artwork.id ?? ""])

                return me
                    .placeBidNetworkModel
                    .bid(provider)
                    .map { return ($0, provider) }
            }
            .flatMap { [weak self] tuple -> Observable<Void> in
                guard let me = self else { return .empty() }
                guard me.placingBid else { return .empty() }

                return me.bidCheckingModel.waitForBidResolution(bidderPositionId: tuple.0, provider: tuple.1).map(void)
            }
    }
}
