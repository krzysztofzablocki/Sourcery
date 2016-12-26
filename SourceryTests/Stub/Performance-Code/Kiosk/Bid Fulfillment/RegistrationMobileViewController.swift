import UIKit
import RxSwift

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let numberIsValid = self.numberTextField.rx.text.asObservable().replaceNil(with: "").map(isZeroLength).not()
        return GenericFormValidationViewModel(isValid: numberIsValid, manualInvocation: self.numberTextField.rx_returnKey, finishedSubject: self.finished)
    }()

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        numberTextField.text = bidDetails.newUser.phoneNumber.value
        numberTextField
            .rx.text
            .asObservable()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.phoneNumber)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx.action = viewModel.command

        numberTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if string.isEmpty { return true }

        // the API doesn't accept chars
        let notNumberChars = CharacterSet.decimalDigits.inverted
        return string.trimmingCharacters(in: notNumberChars).isNotEmpty
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> RegistrationMobileViewController {
        return storyboard.viewController(withID: .RegisterMobile) as! RegistrationMobileViewController
    }
}
