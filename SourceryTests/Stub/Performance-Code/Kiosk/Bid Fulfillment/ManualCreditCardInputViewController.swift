import UIKit
import RxSwift
import Keys

class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finished = PublishSubject<Void>()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!
    @IBOutlet weak var securitycodeTextField: TextField!
    @IBOutlet weak var billingZipTextField: TextField!

    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var securityCodeWrapperView: UIView!
    @IBOutlet weak var billingZipWrapperView: UIView!
    @IBOutlet weak var billingZipErrorLabel: UILabel!

    @IBOutlet weak var cardConfirmButton: ActionButton!
    @IBOutlet weak var dateConfirmButton: ActionButton!
    @IBOutlet weak var securityCodeConfirmButton: ActionButton!
    @IBOutlet weak var billingZipConfirmButton: ActionButton!

    lazy var keys = EidolonKeys()

    lazy var viewModel: ManualCreditCardInputViewModel = {
        var bidDetails = self.navigationController?.fulfillmentNav().bidDetails
        return ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: self.finished)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        expirationDateWrapperView.isHidden = true
        securityCodeWrapperView.isHidden = true
        billingZipWrapperView.isHidden = true

        // We show the enter credit card number, then the date switching the views around
        viewModel
            .cardFullDigits
            .asObservable()
            .bindTo(cardNumberTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .expirationYear
            .asObservable()
            .bindTo(expirationYearTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .expirationMonth
            .asObservable()
            .bindTo(expirationMonthTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .securityCode
            .asObservable()
            .bindTo(securitycodeTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .billingZip
            .asObservable()
            .bindTo(billingZipTextField.rx.text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .creditCardNumberIsValid
            .bindTo(cardConfirmButton.rx.isEnabled)
            .addDisposableTo(rx_disposeBag)

        let action = viewModel.registerButtonCommand()
        billingZipConfirmButton.rx.action = action

        action
            .errors // Based on errors
            .take(1) // On the first error, then forever
            .mapReplace(with: false) // Replace the error with false
            .startWith(true) // But begin with true
            .bindTo(billingZipErrorLabel.rx_hidden) // show the error label
            .addDisposableTo(rx_disposeBag)

        viewModel.moveToYear.take(1).subscribe(onNext: { [weak self] _ in
            self?.expirationYearTextField.becomeFirstResponder()
        }).addDisposableTo(rx_disposeBag)

        cardNumberTextField.becomeFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return viewModel.isEntryValid(string)
    }

    @IBAction func cardNumberconfirmTapped(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = true
        expirationDateWrapperView.isHidden = false
        securityCodeWrapperView.isHidden = true
        billingZipWrapperView.isHidden = true

        expirationDateWrapperView.frame = CGRect(x: 0, y: 0, width: expirationDateWrapperView.frame.width, height: expirationDateWrapperView.frame.height)

        expirationMonthTextField.becomeFirstResponder()
    }

    @IBAction func expirationDateConfirmTapped(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = true
        expirationDateWrapperView.isHidden = true
        securityCodeWrapperView.isHidden = false
        billingZipWrapperView.isHidden = true

        securityCodeWrapperView.frame = CGRect(x: 0, y: 0, width: securityCodeWrapperView.frame.width, height: securityCodeWrapperView.frame.height)

        securitycodeTextField.becomeFirstResponder()
    }

    @IBAction func securityCodeConfirmTapped(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = true
        expirationDateWrapperView.isHidden = true
        securityCodeWrapperView.isHidden = true
        billingZipWrapperView.isHidden = false

        billingZipWrapperView.frame = CGRect(x: 0, y: 0, width: billingZipWrapperView.frame.width, height: billingZipWrapperView.frame.height)

        billingZipTextField.becomeFirstResponder()
    }

    @IBAction func backToCardNumber(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = false
        expirationDateWrapperView.isHidden = true
        securityCodeWrapperView.isHidden = true
        billingZipWrapperView.isHidden = true

        cardNumberTextField.becomeFirstResponder()
    }

    @IBAction func backToExpirationDate(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = true
        expirationDateWrapperView.isHidden = false
        securityCodeWrapperView.isHidden = true
        billingZipWrapperView.isHidden = true

        expirationMonthTextField.becomeFirstResponder()
    }

    @IBAction func backToSecurityCode(_ sender: AnyObject) {
        cardNumberWrapperView.isHidden = true
        expirationDateWrapperView.isHidden = true
        securityCodeWrapperView.isHidden = false
        billingZipWrapperView.isHidden = true

        securitycodeTextField.becomeFirstResponder()
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ManualCreditCardInputViewController {
        return storyboard.viewController(withID: .ManualCardDetailsInput) as! ManualCreditCardInputViewController
    }
}

private extension ManualCreditCardInputViewController {
    func applyCardWithSuccess(_ success: Bool) {
        cardNumberTextField.text = success ? "4242424242424242" : "4000000000000002"
        cardNumberTextField.sendActions(for: .allEditingEvents)
        cardConfirmButton.sendActions(for: .touchUpInside)

        expirationMonthTextField.text = "04"
        expirationMonthTextField.sendActions(for: .allEditingEvents)
        expirationYearTextField.text = "2018"
        expirationYearTextField.sendActions(for: .allEditingEvents)
        dateConfirmButton.sendActions(for: .touchUpInside)

        securitycodeTextField.text = "123"
        securitycodeTextField.sendActions(for: .allEditingEvents)
        securityCodeConfirmButton.sendActions(for: .touchUpInside)

        billingZipTextField.text = "10001"
        billingZipTextField.sendActions(for: .allEditingEvents)
        billingZipTextField.sendActions(for: .touchUpInside)
    }

    @IBAction func dev_creditCardOKTapped(_ sender: AnyObject) {
        applyCardWithSuccess(true)
    }

    @IBAction func dev_creditCardFailTapped(_ sender: AnyObject) {
        applyCardWithSuccess(false)
    }
}
