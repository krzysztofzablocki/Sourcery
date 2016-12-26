import UIKit
import Moya
import RxSwift
import Action

class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var useArtsyBidderButton: UIButton!
    @IBOutlet var confirmCredentialsButton: Button!

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    var createNewAccount = false
    var provider: Networking!

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidArtsyLoginViewController {
        return storyboard.viewController(withID: .ConfirmYourBidArtsyLogin) as! ConfirmYourBidArtsyLoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyBidderButton.title(for: useArtsyBidderButton.state) ?? ""
        let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSFontAttributeName: useArtsyBidderButton.titleLabel!.font] as [String : Any]
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyBidderButton.setAttributedTitle(attrTitle, for:useArtsyBidderButton.state)

        let nav = self.fulfillmentNav()
        let bidDetails = nav.bidDetails
        bidDetailsPreviewView.bidDetails = bidDetails

        emailTextField.text = nav.bidDetails.newUser.email.value ?? ""

        let emailText = emailTextField.rx.text.takeUntil(viewWillDisappear)
        let passwordText = passwordTextField.rx.text.takeUntil(viewWillDisappear)

        emailText
            .bindTo(nav.bidDetails.newUser.email)
            .addDisposableTo(rx_disposeBag)

        passwordText
            .bindTo(nav.bidDetails.newUser.password)
            .addDisposableTo(rx_disposeBag)

        let inputIsEmail = emailText.asObservable().replaceNil(with: "").map(stringIsEmailAddress)
        let passwordIsLongEnough = passwordText.asObservable().replaceNil(with: "").map(isZeroLength).not()
        let formIsValid = [inputIsEmail, passwordIsLongEnough].combineLatestAnd()

        let provider = self.provider

        confirmCredentialsButton.rx.action = CocoaAction(enabledIf: formIsValid) { [weak self] _ -> Observable<Void> in
            guard let me = self else { return .empty() }

            return bidDetails.authenticatedNetworking(provider: provider!)
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return me.fulfillmentNav()
                        .updateUserCredentials(loggedInProvider: provider)
                        .mapReplace(with: provider)
                }.flatMap { provider -> Observable<Void> in
                    return me.creditCard(provider)
                        .doOnNext { cards in
                            guard let me = self else { return }

                            if cards.count > 0 {
                                me.performSegue(.EmailLoginConfirmedHighestBidder)
                            } else {
                                me.performSegue(.ArtsyUserHasNotRegisteredCard)
                            }
                        }
                        .map(void)

                }.doOnError { [weak self] error in
                    logger.log("Error logging in: \((error as NSError).localizedDescription)")
                    logger.log("Error Logging in, likely bad auth creds, email = \(self?.emailTextField.text)")
                    self?.showAuthenticationError()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue == .EmailLoginConfirmedHighestBidder {
            let viewController = segue.destination as! LoadingViewController
            viewController.provider = provider
        } else if segue == .ArtsyUserHasNotRegisteredCard {
            let viewController = segue.destination as! RegisterViewController
            viewController.provider = provider
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if emailTextField.text.isNilOrEmpty {
            emailTextField.becomeFirstResponder()
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    func showAuthenticationError() {
        confirmCredentialsButton.flashError("Wrong login info")
        passwordTextField.flashForError()
        fulfillmentNav().bidDetails.newUser.password.value = ""
        passwordTextField.text = ""
    }

    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Forgot Password", message: "Please enter your email address and we'll send you a reset link.", preferredStyle: .alert)

        var submitAction = UIAlertAction.Action("Send", style: .default)
        let email = Variable("")
        submitAction.rx.action = CocoaAction(enabledIf: email.asObservable().map(stringIsEmailAddress), workFactory: { () -> Observable<Void> in
            let endpoint: ArtsyAPI = ArtsyAPI.lostPasswordNotification(email: email.value)

            return self.provider.request(endpoint)
                .filterSuccessfulStatusCodes()
                .doOnNext { _ in
                    logger.log("Sent forgot password request")
                }
                .map(void)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

        alertController.addTextField { textField in
            textField.placeholder = "email@domain.com"
            textField.text = self.emailTextField.text

            textField
                .rx.text
                .asObservable()
                .replaceNil(with: "")
                .bindTo(email)
                .addDisposableTo(textField.rx_disposeBag)

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                submitAction.isEnabled = stringIsEmailAddress(textField.text ?? "").boolValue
            }
        }

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true) {}
    }

    func creditCard(_ provider: AuthorizedNetworking) -> Observable<[Card]> {
        let endpoint = ArtsyAuthenticatedAPI.myCreditCards
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(arrayOf: Card.self)
    }

    @IBAction func useBidderTapped(_ sender: AnyObject) {
        for controller in navigationController!.viewControllers {
            if controller.isKind(of: ConfirmYourBidViewController.self) {
                navigationController!.popToViewController(controller, animated:true)
                break
            }
        }
    }
}

private extension  ConfirmYourBidArtsyLoginViewController {

    @IBAction func dev_hasCardTapped(_ sender: AnyObject) {
        self.performSegue(.EmailLoginConfirmedHighestBidder)
    }

    @IBAction func dev_noCardFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ArtsyUserHasNotRegisteredCard)
    }

}
