import UIKit
import Artsy_UILabels
import RxSwift
import Artsy_UIButtons
import Artsy_UILabels
import ORStackView
import Action

class PlaceBidViewController: UIViewController {

    var provider: Networking!

    fileprivate var _bidDollars = Variable(0)
    var hasAlreadyPlacedABid: Bool = false

    @IBOutlet var bidAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidTitleLabel: UILabel!
    @IBOutlet var yourBidTitleLabel: UILabel!
    @IBOutlet var currentBidAmountLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet weak var detailsStackView: ORTagBasedAutoStackView!

    @IBOutlet var bidButton: Button!
    @IBOutlet weak var conditionsOfSaleButton: UIButton!
    @IBOutlet weak var privacyPolictyButton: UIButton!

    var showBuyersPremiumCommand = { () -> CocoaAction in
        appDelegate().showBuyersPremiumCommand()
    }

    var showPrivacyPolicyCommand = { () -> CocoaAction in
        appDelegate().showPrivacyPolicyCommand()
    }

    var showConditionsOfSaleCommand = { () -> CocoaAction in
        appDelegate().showConditionsOfSaleCommand()
    }

    lazy var bidDollars: Observable<Int> = { self.keypadContainer.intValue }()
    var buyersPremium: () -> (BuyersPremium?) = { appDelegate().sale.buyersPremium }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> PlaceBidViewController {
        return storyboard.viewController(withID: .PlaceYourBid) as! PlaceBidViewController
    }

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !hasAlreadyPlacedABid {
            self.fulfillmentNav().reset()
        }

        currentBidTitleLabel.font = UIFont.serifSemiBoldFont(withSize: 17)
        yourBidTitleLabel.font = UIFont.serifSemiBoldFont(withSize: 17)

        conditionsOfSaleButton.rx.action = showConditionsOfSaleCommand()
        privacyPolictyButton.rx.action = showPrivacyPolicyCommand()

        bidDollars
            .bindTo(_bidDollars)
            .addDisposableTo(rx_disposeBag)

        bidDollars
            .map(dollarsToCurrencyString)
            .bindTo(bidAmountTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        if let nav = self.navigationController as? FulfillmentNavigationController {
            bidDollars
                .map { $0 * 100 }
                .takeUntil(viewWillDisappear)
                .map { bid in
                    return bid as NSNumber?
                }
                .bindTo(nav.bidDetails.bidAmountCents)
                .addDisposableTo(rx_disposeBag)

            if let saleArtwork = nav.bidDetails.saleArtwork {

                let minimumNextBid = saleArtwork
                    .rx.observe(NSNumber.self, "minimumNextBidCents")
                    .filterNil()
                    .map { $0 as Int }

                saleArtwork.viewModel
                    .currentBidOrOpeningBidLabel()
                    .mapToOptional()
                    .bindTo(currentBidTitleLabel.rx.text)
                    .addDisposableTo(rx_disposeBag)

                saleArtwork.viewModel
                    .currentBidOrOpeningBid()
                    .mapToOptional()
                    .bindTo(currentBidAmountLabel.rx.text)
                    .addDisposableTo(rx_disposeBag)

                minimumNextBid
                    .map { $0 as Int }
                    .map(toNextBidString)
                    .bindTo(nextBidAmountLabel.rx.text)
                    .addDisposableTo(rx_disposeBag)

                Observable.combineLatest([bidDollars, minimumNextBid], { ints  in
                        return (ints[0]) * 100 >= (ints[1])
                    })
                    .bindTo(bidButton.rx.isEnabled)
                    .addDisposableTo(rx_disposeBag)

                enum LabelTags: Int {
                    case lotNumber = 1
                    case artistName
                    case artworkTitle
                    case artworkPrice
                    case buyersPremium
                    case gobbler
                }

                let lotNumber = nav.bidDetails.saleArtwork?.lotNumber

                if let _ = lotNumber {
                    let lotNumberLabel = smallSansSerifLabel()
                    lotNumberLabel.tag = LabelTags.lotNumber.rawValue
                    detailsStackView.addSubview(lotNumberLabel, withTopMargin: "10", sideMargin: "0")
                    saleArtwork.viewModel
                        .lotNumber()
                        .filterNilKeepOptional()
                        .takeUntil(viewWillDisappear)
                        .bindTo(lotNumberLabel.rx.text)
                        .addDisposableTo(rx_disposeBag)

                }

                let artistNameLabel = sansSerifLabel()
                artistNameLabel.tag = LabelTags.artistName.rawValue
                detailsStackView.addSubview(artistNameLabel, withTopMargin: "15", sideMargin: "0")

                let artworkTitleLabel = serifLabel()
                artworkTitleLabel.tag = LabelTags.artworkTitle.rawValue
                detailsStackView.addSubview(artworkTitleLabel, withTopMargin: "15", sideMargin: "0")

                let artworkPriceLabel = serifLabel()
                artworkPriceLabel.tag = LabelTags.artworkPrice.rawValue
                detailsStackView.addSubview(artworkPriceLabel, withTopMargin: "15", sideMargin: "0")

                if let _ = buyersPremium() {
                    let buyersPremiumView = UIView()
                    buyersPremiumView.tag = LabelTags.buyersPremium.rawValue

                    let buyersPremiumLabel = ARSerifLabel()
                    buyersPremiumLabel.font = buyersPremiumLabel.font.withSize(16)
                    buyersPremiumLabel.text = "This work has a "
                    buyersPremiumLabel.textColor = .artsyGrayBold()

                    var buyersPremiumButton = ARUnderlineButton()
                    buyersPremiumButton.titleLabel?.font = buyersPremiumLabel.font
                    buyersPremiumButton.setTitle("buyers premium", for: .normal)
                    buyersPremiumButton.setTitleColor(.artsyGrayBold(), for: .normal)
                    buyersPremiumButton.rx.action = showBuyersPremiumCommand()

                    buyersPremiumView.addSubview(buyersPremiumLabel)
                    buyersPremiumView.addSubview(buyersPremiumButton)

                    buyersPremiumLabel.alignTop("0", leading: "0", bottom: "0", trailing: nil, to: buyersPremiumView)
                    buyersPremiumLabel.alignBaseline(with: buyersPremiumButton, predicate: nil)
                    buyersPremiumButton.alignAttribute(.left, to: .right, of: buyersPremiumLabel, predicate: "0")

                    detailsStackView.addSubview(buyersPremiumView, withTopMargin: "15", sideMargin: "0")
                }

                let gobbler = WhitespaceGobbler()
                gobbler.tag = LabelTags.gobbler.rawValue
                detailsStackView.addSubview(gobbler, withTopMargin: "0")

                if let artist = saleArtwork.artwork.artists?.first {
                    artist
                        .rx.observe(String.self, "name")
                        .filterNil()
                        .mapToOptional()
                        .bindTo(artistNameLabel.rx.text)
                        .addDisposableTo(rx_disposeBag)
                }

                saleArtwork
                    .artwork
                    .rx.observe(NSAttributedString.self, "titleAndDate")
                    .takeUntil(rx.deallocated)
                    .bindTo(artworkTitleLabel.rx.attributedText)
                    .addDisposableTo(rx_disposeBag)

                saleArtwork
                    .artwork
                    .rx.observe(String.self, "price")
                    .filterNil()
                    .mapToOptional()
                    .takeUntil(rx.deallocated)
                    .bindTo(artworkPriceLabel.rx.text)
                    .addDisposableTo(rx_disposeBag)

                if let url = saleArtwork.artwork.defaultImage?.thumbnailURL() {
                    self.artworkImageView.sd_setImage(with: url as URL!)
                } else {
                    self.artworkImageView.image = nil
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    @IBAction func bidButtonTapped(_ sender: AnyObject) {
        let identifier = hasAlreadyPlacedABid ? SegueIdentifier.PlaceAnotherBid : SegueIdentifier.ConfirmBid
        performSegue(identifier)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue == .PlaceAnotherBid {
            let nextViewController = segue.destination as! LoadingViewController
            nextViewController.provider = provider
            nextViewController.placingBid = true
        } else if segue == .ConfirmBid {
            let viewController = segue.destination as! ConfirmYourBidViewController
            viewController.provider = provider
        }
    }
}

private extension PlaceBidViewController {
    func smallSansSerifLabel() -> UILabel {
        let label = sansSerifLabel()
        label.font = label.font.withSize(12)
        return label
    }

    func sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.numberOfLines = 1
        return label
    }

    func serifLabel() -> UILabel {
        let label = ARSerifLabel()
        label.numberOfLines = 1
        label.font = label.font.withSize(16)
        return label
    }
}

/// These are for RAC only

func dollarsToCurrencyString(_ dollars: Int) -> String {
    if dollars == 0 {
        return ""
    }

    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    return formatter.string(from: dollars as NSNumber) ?? ""
}

func toNextBidString(_ cents: Int) -> String {
    guard let dollars = NumberFormatter.currencyString(forDollarCents: cents as NSNumber!)  else {
        return ""
    }
    return "Enter \(dollars) or more"
}

typealias DeveloperOnly = PlaceBidViewController
extension DeveloperOnly {
    @IBAction func dev_nextIncrementPressed(_ sender: AnyObject) {
        let bidDetails = (self.navigationController as? FulfillmentNavigationController)?.bidDetails
        bidDetails?.bidAmountCents.value = bidDetails?.saleArtwork?.minimumNextBidCents
        performSegue(SegueIdentifier.ConfirmBid)
    }
}
