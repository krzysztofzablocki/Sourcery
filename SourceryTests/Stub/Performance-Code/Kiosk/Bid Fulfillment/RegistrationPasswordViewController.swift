import UIKit
import RxSwift
import Moya
import Action

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var forgotPasswordButton: UIButton!

    let finished = PublishSubject<Void>()

    var provider: Networking!

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var viewModel: RegistrationPasswordViewModelType = {
        let email = self.navigationController?.fulfillmentNav().bidDetails.newUser.email.value ?? ""

        return RegistrationPasswordViewModel(
            provider: self.provider,
            password: self.passwordTextField.rx.text.asObservable().replaceNil(with: ""),
            execute: self.passwordTextField.rx_returnKey,
            completed: self.finished,
            email: email)
    }()

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        forgotPasswordButton.isHidden = false

        let passwordText = passwordTextField.rx.text
        passwordText
            .asObservable()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.password)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx.action = viewModel.action

        viewModel
            .action
            .errors
            .subscribe(onNext: { [weak self] _ in
                self?.showAuthenticationError()
                return
            })
            .addDisposableTo(rx_disposeBag)

        viewModel
            .emailExists
            .not()
            .startWith(true)
            .bindTo(forgotPasswordButton.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        forgotPasswordButton.rx.action = CocoaAction { [weak self] _ in
            return self?
                .viewModel
                .userForgotPassword()
                .then {
                    self?.alertUserPasswordSent()
                } ?? .empty()
        }

        viewModel
            .emailExists
            .map { emailExists in
                if emailExists {
                    return "Enter your Artsy password"
                } else {
                    return "Create a password"
                }
            }
            .bindTo(subtitleLabel.rx.text)
            .addDisposableTo(rx_disposeBag)

        passwordTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    func alertUserPasswordSent() -> Observable<Void> {
        return Observable.create { observer in

            let alertController = UIAlertController(title: "Forgot Password", message: "We have sent you your password.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in }

            alertController.addAction(okAction)

            self.present(alertController, animated: true) {
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func showAuthenticationError() {
        confirmButton.flashError("Incorrect")
        passwordTextField.flashForError()
        confirmButton.setEnabled(false, animated: false)
        navigationController!.fulfillmentNav().bidDetails.newUser.password.value = ""
        passwordTextField.text = ""
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> RegistrationPasswordViewController {
        return storyboard.viewController(withID: .RegisterPassword) as! RegistrationPasswordViewController
    }
}
