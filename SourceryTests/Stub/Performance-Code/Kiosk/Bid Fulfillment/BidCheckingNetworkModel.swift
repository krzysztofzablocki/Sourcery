import UIKit
import RxSwift
import Moya

enum BidCheckingError: String {
    case PollingExceeded
}

extension BidCheckingError: Swift.Error { }

protocol BidCheckingNetworkModelType {
    var bidDetails: BidDetails { get }

    var bidIsResolved: Variable<Bool> { get }
    var isHighestBidder: Variable<Bool> { get }
    var reserveNotMet: Variable<Bool> { get }

    func waitForBidResolution (bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void>
}

class BidCheckingNetworkModel: NSObject, BidCheckingNetworkModelType {

    fileprivate var pollInterval = TimeInterval(1)
    fileprivate var maxPollRequests = 20
    fileprivate var pollRequests = 0

    // inputs
    let provider: Networking
    let bidDetails: BidDetails

    // outputs
    var bidIsResolved = Variable(false)
    var isHighestBidder = Variable(false)
    var reserveNotMet = Variable(false)

    fileprivate var mostRecentSaleArtwork: SaleArtwork?

    init(provider: Networking, bidDetails: BidDetails) {
        self.provider = provider
        self.bidDetails = bidDetails
    }

    func waitForBidResolution (bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void> {
        return self
            .poll(forUpdatedBidderPosition: bidderPositionId, provider: provider)
            .then {

                return self.getUpdatedSaleArtwork()
                    .flatMap { saleArtwork -> Observable<Void> in

                        // This is an updated model – hooray!
                        self.mostRecentSaleArtwork = saleArtwork
                        self.bidDetails.saleArtwork?.updateWithValues(saleArtwork)
                        self.reserveNotMet.value = ReserveStatus.initOrDefault(saleArtwork.reserveStatus).reserveNotMet

                        return .just(Void())
                    }
                    .doOnError { _ in
                        logger.log("Bidder position was processed but corresponding saleArtwork was not found")
                    }
                    .catchErrorJustReturn()
                    .flatMap { _ -> Observable<Void> in
                        return self.checkForMaxBid(provider: provider)
                }
            } .doOnNext { _ in
                self.bidIsResolved.value = true

                // If polling fails, we can still show bid confirmation. Do not error.
            }.catchErrorJustReturn()
    }

    fileprivate func poll(forUpdatedBidderPosition bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void> {
        let updatedBidderPosition = getUpdatedBidderPosition(bidderPositionId: bidderPositionId, provider: provider)
            .flatMap { bidderPositionObject -> Observable<Void> in
                self.pollRequests += 1

                logger.log("Polling \(self.pollRequests) of \(self.maxPollRequests) for updated sale artwork")

                if let processedAt = bidderPositionObject.processedAt {
                    logger.log("BidPosition finished processing at \(processedAt), proceeding...")
                    return .just(Void())
                } else {
                    // The backend hasn't finished processing the bid yet

                    guard self.pollRequests < self.maxPollRequests else {
                        // We have exceeded our max number of polls, fail.
                        throw BidCheckingError.PollingExceeded
                    }

                    // We didn't get an updated value, so let's try again.
                    return Observable<Int>.interval(self.pollInterval, scheduler: MainScheduler.instance)
                        .take(1)
                        .map(void)
                        .then {
                            return self.poll(forUpdatedBidderPosition: bidderPositionId, provider: provider)
                    }
                }
        }

        return Observable<Int>.interval(pollInterval, scheduler: MainScheduler.instance)
            .take(1)
            .map(void)
            .then { updatedBidderPosition }
    }

    fileprivate func checkForMaxBid(provider: AuthorizedNetworking) -> Observable<Void> {
        return getMyBidderPositions(provider: provider)
            .doOnNext { newBidderPositions in

                if let topBidID = self.mostRecentSaleArtwork?.saleHighestBid?.id {
                    for position in newBidderPositions where position.highestBid?.id == topBidID {
                        self.isHighestBidder.value = true
                    }
                }
            }
            .map(void)
    }

    fileprivate func getMyBidderPositions(provider: AuthorizedNetworking) -> Observable<[BidderPosition]> {
        let artworkID = bidDetails.saleArtwork!.artwork.id
        let auctionID = bidDetails.saleArtwork!.auctionID!

        let endpoint = ArtsyAuthenticatedAPI.myBidPositionsForAuctionArtwork(auctionID: auctionID, artworkID: artworkID)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(arrayOf: BidderPosition.self)
    }

    fileprivate func getUpdatedSaleArtwork() -> Observable<SaleArtwork> {

        let artworkID = bidDetails.saleArtwork!.artwork.id
        let auctionID = bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.auctionInfoForArtwork(auctionID: auctionID, artworkID: artworkID)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(object: SaleArtwork.self)
    }

    fileprivate func getUpdatedBidderPosition(bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<BidderPosition> {
        let endpoint = ArtsyAuthenticatedAPI.myBidPosition(id: bidderPositionId)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(object: BidderPosition.self)
    }
}
