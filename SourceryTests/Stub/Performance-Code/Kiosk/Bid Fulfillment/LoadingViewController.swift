import UIKit
import Artsy_UILabels
import ARAnalytics
import RxSwift

class LoadingViewController: UIViewController {

    var provider: Networking!

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var statusMessage: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    var placingBid = true

    var animate = true

    @IBOutlet weak var backToAuctionButton: SecondaryActionButton!
    @IBOutlet weak var placeHigherBidButton: ActionButton!

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var viewModel: LoadingViewModelType = {
        return LoadingViewModel(
            provider: self.provider,
            bidNetworkModel: BidderNetworkModel(provider: self.provider, bidDetails: self.fulfillmentNav().bidDetails),
            placingBid: self.placingBid,
            actionsComplete: self.viewWillDisappear
        )
    }()

    lazy var recognizer = UITapGestureRecognizer()
    lazy var closeSelf: () -> Void = { [weak self] in
        self?.fulfillmentContainer()?.closeFulfillmentModal()
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if placingBid {
            bidDetailsPreviewView.bidDetails = viewModel.bidDetails
        } else {
            bidDetailsPreviewView.isHidden = true
        }

        statusMessage.isHidden = true
        backToAuctionButton.isHidden = true
        placeHigherBidButton.isHidden = true

        spinner.animate(animate)

        titleLabel.text = placingBid ? "Placing bid..." : "Registering..."

        // Either finishUp() or bidderError() are responsible for providing a way back to the auction.
        fulfillmentContainer()?.cancelButton.isHidden = true

        // The view model will perform actions like registering a user if necessary,
        // placing a bid if requested, and polling for results.
        viewModel.performActions().subscribe(onNext: nil,
            onError: { [weak self] error in
                logger.log("Bidder error \(error)")
                self?.bidderError(error as NSError)
            },
            onCompleted: { [weak self] in
                logger.log("Bid placement and polling completed")
                self?.finishUp()
            },
            onDisposed: { [weak self] in
                // Regardless of error or completion. hide the spinner.
                self?.spinner.isHidden = true
            })
            .addDisposableTo(rx_disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .PushtoRegisterConfirmed {
            let detailsVC = segue.destination as! YourBiddingDetailsViewController
            detailsVC.confirmationImage = bidConfirmationImageView.image
            detailsVC.provider = provider
        }

        if segue == .PlaceaHigherBidAfterNotBeingHighestBidder {
            let placeBidVC = segue.destination as! PlaceBidViewController
            placeBidVC.hasAlreadyPlacedABid = true
            placeBidVC.provider = provider
        }
    }
}

extension LoadingViewController {

    func finishUp() {
        let reserveNotMet = viewModel.reserveNotMet.value
        let isHighestBidder = viewModel.isHighestBidder.value
        let bidIsResolved = viewModel.bidIsResolved.value
        let createdNewBidder = viewModel.createdNewBidder.value

        logger.log("Bidding process result: reserveNotMet \(reserveNotMet), isHighestBidder \(isHighestBidder), bidIsResolved \(bidIsResolved), createdNewbidder \(createdNewBidder)")

        if placingBid {
            ARAnalytics.event("Placed a bid", withProperties: ["top_bidder" : isHighestBidder, "sale_artwork": viewModel.bidDetails.saleArtwork?.artwork.id ?? ""])

            if bidIsResolved {

                if reserveNotMet {
                    handleReserveNotMet()
                } else if isHighestBidder {
                    handleHighestBidder()
                } else {
                    handleLowestBidder()
                }

            } else {
                handleUnknownBidder()
            }

        } else { // Not placing bid
            if createdNewBidder { // Creating new user
                handleRegistered()
            } else { // Updating existing user
                handleUpdate()
            }
        }

        let showPlaceHigherButton = placingBid && (!isHighestBidder || reserveNotMet)
        placeHigherBidButton.isHidden = !showPlaceHigherButton

        let showAuctionButton = showPlaceHigherButton || isHighestBidder || (!placingBid && !createdNewBidder)
        backToAuctionButton.isHidden = !showAuctionButton

        let title = reserveNotMet ? "NO, THANKS" : (createdNewBidder ? "CONTINUE" : "BACK TO AUCTION")
        backToAuctionButton.setTitle(title, for: .normal)
        fulfillmentContainer()?.cancelButton.isHidden = false
    }

    func handleRegistered() {
        titleLabel.text = "Registration Complete"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
        fulfillmentContainer()?.cancelButton.setTitle("DONE", for: .normal)
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onCompleted: { [weak self] in
                self?.performSegue(.PushtoRegisterConfirmed)
            })
            .addDisposableTo(rx_disposeBag)
    }

    func handleUpdate() {
        titleLabel.text = "Updated your Information"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
        fulfillmentContainer()?.cancelButton.setTitle("DONE", for: .normal)
    }

    func handleUnknownBidder() {
        titleLabel.text = "Bid Submitted"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleReserveNotMet() {
        titleLabel.text = "Reserve Not Met"
        statusMessage.isHidden = false
        statusMessage.text = "Your bid is still below this lot's reserve. Please place a higher bid."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
    }

    func handleHighestBidder() {
        titleLabel.text = "High Bid!"
        statusMessage.isHidden = false
        statusMessage.text = "You are the high bidder for this lot."
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")

        recognizer.rx.event.subscribe(onNext: { [weak self] _ in
            self?.closeSelf()
        }).addDisposableTo(rx_disposeBag)

        bidConfirmationImageView.isUserInteractionEnabled = true
        bidConfirmationImageView.addGestureRecognizer(recognizer)

        fulfillmentContainer()?.cancelButton.setTitle("DONE", for: .normal)
    }

    func handleLowestBidder() {
        titleLabel.text = "Higher bid needed"

        titleLabel.textColor = .artsyRedRegular()
        statusMessage.isHidden = false
        statusMessage.text = "Another bidder has placed a higher maximum bid. Place a higher bid to secure the lot."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
        placeHigherBidButton.isHidden = false
    }

    // MARK: - Error Handling

    func bidderError(_ error: NSError) {
        if placingBid {
            // If you are bidding, we show a bidding error regardless of whether or not you're also registering.
            if error.domain == OutbidDomain {
                handleLowestBidder()
            } else {
                bidPlacementFailed(error: error)
            }
        } else {
            // If you're not placing a bid, you're here because you're .just registering.
            handleRegistrationFailed(error: error)
        }
    }

    func handleRegistrationFailed(error: NSError) {
        handleError(withTitle: "Registration Failed",
            message: "There was a problem registering for the auction. Please speak to an Artsy representative.",
            error: error)
    }

    func bidPlacementFailed(error: NSError) {
        handleError(withTitle: "Bid Failed",
            message: "There was a problem placing your bid. Please speak to an Artsy representative.",
            error: error)
    }

    func handleError(withTitle title: String, message: String, error: NSError) {
        titleLabel.textColor = .artsyRedRegular()
        titleLabel.text = title
        statusMessage.text = message
        statusMessage.isHidden = false
        backToAuctionButton.isHidden = false

        statusMessage.presentOnLongPress("Error: \(error.localizedDescription). \n \(error.artsyServerError())", title: title) { [weak self] alertController in
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func placeHigherBidTapped(_ sender: AnyObject) {
        self.fulfillmentNav().bidDetails.bidAmountCents.value = 0
        self.performSegue(.PlaceaHigherBidAfterNotBeingHighestBidder)
    }

    @IBAction func backToAuctionTapped(_ sender: AnyObject) {
        if viewModel.createdNewBidder.value {
            self.performSegue(.PushtoRegisterConfirmed)
        } else {
            closeSelf()
        }
    }
}
