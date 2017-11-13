import UIKit
import ECPhoneNumberFormatter
import Moya
import RxSwift
import Action

class ConfirmYourBidViewController: UIViewController {

    fileprivate var _number = Variable("")
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var numberAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var useArtsyLoginButton: UIButton!

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    // Need takeUntil because we bind this observable eventually to bidDetails, making us stick around longer than we should!
    lazy var number: Observable<String> = { self.keypadContainer.stringValue.takeUntil(self.viewWillDisappear) }()

    var provider: Networking!

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidViewController {
        return storyboard.viewController(withID: .ConfirmYourBid) as! ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyLoginButton.title(for: useArtsyLoginButton.state)!
        let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSFontAttributeName: useArtsyLoginButton.titleLabel!.font] as [String : Any]
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyLoginButton.setAttributedTitle(attrTitle, for:useArtsyLoginButton.state)

        number
            .bindTo(_number)
            .addDisposableTo(rx_disposeBag)

        number
            .map(toPhoneNumberString)
            .bindTo(numberAmountTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails

        let optionalNumber = number.mapToOptional()

        // We don't know if it's a paddle number or a phone number yet, so bind both ¯\_(ツ)_/¯
        [nav.bidDetails.paddleNumber, nav.bidDetails.newUser.phoneNumber].forEach { variable in
            optionalNumber
                .bindTo(variable)
                .addDisposableTo(rx_disposeBag)
        }

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email

        let auctionID = nav.auctionID ?? ""

        let numberIsZeroLength = number.map(isZeroLength)

        enterButton.rx.action = CocoaAction(enabledIf: numberIsZeroLength.not(), workFactory: { [weak self] _ in
            guard let me = self else { return .empty() }

            let endpoint = ArtsyAPI.findBidderRegistration(auctionID: auctionID, phone: String(me._number.value))

            return me.provider.request(endpoint)
                .filterStatusCode(400)
                .map(void)
                .doOnError { error in
                    guard let me = self else { return }

                    // Due to AlamoFire restrictions we can't stop HTTP redirects
                    // so to figure out if we got 302'd we have to introspect the
                    // error to see if it's the original URL to know if the
                    // request succeeded.

                    var response: Moya.Response?

                    if case .statusCode(let receivedResponse)? = error as? Moya.Error {
                        response = receivedResponse
                    }

                    if let responseURL = response?.response?.url?.absoluteString, responseURL.contains("v1/bidder/") {

                        me.performSegue(.ConfirmyourBidBidderFound)
                    } else {
                        me.performSegue(.ConfirmyourBidBidderNotFound)
                    }
                }

        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .ConfirmyourBidBidderFound {
            let nextViewController = segue.destination as! ConfirmYourBidPINViewController
            nextViewController.provider = provider
        } else if segue == .ConfirmyourBidBidderNotFound {
            let viewController = segue.destination as! ConfirmYourBidEnterYourEmailViewController
            viewController.provider = provider
        } else if segue == .ConfirmyourBidArtsyLogin {
            let viewController = segue.destination as! ConfirmYourBidArtsyLoginViewController
            viewController.provider = provider
        } else if segue == .ConfirmyourBidBidderFound {
            let viewController = segue.destination as! ConfirmYourBidPINViewController
            viewController.provider = provider
        }
    }

    func toOpeningBidString(_ cents: AnyObject!) -> AnyObject! {
        if let dollars = NumberFormatter.currencyString(forDollarCents: cents as? Int as NSNumber!) {
            return "Enter \(dollars) or more" as AnyObject!
        }
        return "" as AnyObject!
    }

    func toPhoneNumberString(_ number: String) -> String {
        if number.count >= 7 {
            return phoneNumberFormatter.string(for: number) ?? number
        } else {
            return number
        }
    }
}

private extension ConfirmYourBidViewController {

    @IBAction func dev_noPhoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidArtsyLogin )
    }

    @IBAction func dev_phoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}
