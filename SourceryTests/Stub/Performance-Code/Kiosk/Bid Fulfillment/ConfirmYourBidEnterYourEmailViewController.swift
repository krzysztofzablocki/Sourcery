import UIKit
import RxSwift
import RxCocoa
import Action

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidEnterYourEmailViewController {
        return storyboard.viewController(withID: .ConfirmYourBidEnterEmail) as! ConfirmYourBidEnterYourEmailViewController
    }

    var provider: Networking!

    override func viewDidLoad() {
        super.viewDidLoad()

        let emailText = emailTextField.rx.textInput.text.asObservable().replaceNil(with: "")
        let inputIsEmail = emailText.map(stringIsEmailAddress)

        let action = CocoaAction(enabledIf: inputIsEmail) { [weak self] _ in
            guard let me = self else { return .empty() }

            let endpoint: ArtsyAPI = ArtsyAPI.findExistingEmailRegistration(email: me.emailTextField.text ?? "")

            return self?.provider.request(endpoint)
                .filterStatusCode(200)
                .doOnNext { _ in
                    me.performSegue(.ExistingArtsyUserFound)
                }
                .doOnError { error in

                    self?.performSegue(.EmailNotFoundonArtsy)
                }
                .map(void) ?? .empty()
        }

        confirmButton.rx.action = action

        let unbind = action.executing.ignore(value: false)

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails

        emailText
            .asObservable()
            .mapToOptional()
            .takeUntil(unbind)
            .bindTo(nav.bidDetails.newUser.email)
            .addDisposableTo(rx_disposeBag)

        emailTextField.rx_returnKey.subscribe(onNext: { _ in
            action.execute()
        }).addDisposableTo(rx_disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.emailTextField.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue == .EmailNotFoundonArtsy {
            let viewController = segue.destination as! RegisterViewController
            viewController.provider = provider
        } else if segue == .ExistingArtsyUserFound {
            let viewController = segue.destination as! ConfirmYourBidArtsyLoginViewController
            viewController.provider = provider
        }
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {

    @IBAction func dev_emailFound(_ sender: AnyObject) {
        performSegue(.ExistingArtsyUserFound)
    }

    @IBAction func dev_emailNotFound(_ sender: AnyObject) {
        performSegue(.EmailNotFoundonArtsy)
    }

}
