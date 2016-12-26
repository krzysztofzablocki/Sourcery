import UIKit
import ORStackView
import Artsy_UILabels
import Artsy_UIButtons
import Action
import RxSwift
import RxCocoa

class HelpViewController: UIViewController {
    var positionConstraints: [NSLayoutConstraint]?
    var dismissTapGestureRecognizer: UITapGestureRecognizer?

    fileprivate let stackView = ORTagBasedAutoStackView()

    fileprivate var buyersPremiumButton: UIButton!

    fileprivate let sideMargin: Float = 90.0
    fileprivate let topMargin: Float = 45.0
    fileprivate let headerMargin: Float = 25.0
    fileprivate let inbetweenMargin: Float = 10.0

    var showBuyersPremiumCommand = { () -> CocoaAction in
        appDelegate().showBuyersPremiumCommand()
    }

    var registerToBidCommand = { (enabled: Observable<Bool>) -> CocoaAction in
        appDelegate().registerToBidCommand(enabled: enabled)
    }

    var requestBidderDetailsCommand = { (enabled: Observable<Bool>) -> CocoaAction in
        appDelegate().requestBidderDetailsCommand(enabled: enabled)
    }

    var showPrivacyPolicyCommand = { () -> CocoaAction in
        appDelegate().showPrivacyPolicyCommand()
    }

    var showConditionsOfSaleCommand = { () -> CocoaAction in
        appDelegate().showConditionsOfSaleCommand()
    }

    lazy var hasBuyersPremium: Observable<Bool> = {
        return appDelegate()
            .appViewController
            .sale
            .value
            .rx.observe(String.self, "buyersPremium")
            .map { $0.hasValue }
    }()

    class var width: Float {
        get {
            return 415.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure view
        view.backgroundColor = .white

        addSubviews()
    }
}

private extension HelpViewController {

    enum SubviewTag: Int {
        case assistanceLabel = 0
        case stuckLabel, stuckExplainLabel
        case bidLabel, bidExplainLabel
        case registerButton
        case bidderDetailsLabel, bidderDetailsExplainLabel, bidderDetailsButton
        case conditionsOfSaleButton, buyersPremiumButton, privacyPolicyButton
    }

    func addSubviews() {

        // Configure subviews
        let assistanceLabel = ARSerifLabel()
        assistanceLabel.font = assistanceLabel.font.withSize(35)
        assistanceLabel.text = "Assistance"
        assistanceLabel.tag = SubviewTag.assistanceLabel.rawValue

        let stuckLabel = titleLabel(tag: .stuckLabel, title: "Stuck in the process?")

        let stuckExplainLabel = wrappingSerifLabel(tag: .stuckExplainLabel, text: "Find the nearest Artsy representative and they will assist you.")

        let bidLabel = titleLabel(tag: .bidLabel, title: "How do I place a bid?")

        let bidExplainLabel = wrappingSerifLabel(tag: .bidExplainLabel, text: "Enter the amount you would like to bid. You will confirm this bid in the next step. Enter your mobile number or bidder number and PIN that you received when you registered.")
        bidExplainLabel.makeSubstringsBold(["mobile number", "bidder number", "PIN"])

        var registerButton = blackButton(tag: .registerButton, title: "Register")
        registerButton.rx.action = registerToBidCommand(connectedToInternetOrStubbing())

        let bidderDetailsLabel = titleLabel(tag: .bidderDetailsLabel, title: "What Are Bidder Details?")

        let bidderDetailsExplainLabel = wrappingSerifLabel(tag: .bidderDetailsExplainLabel, text: "The bidder number is how you can identify yourself to bid and see your place in bid history. The PIN is a four digit number that authenticates your bid.")
        bidderDetailsExplainLabel.makeSubstringsBold(["bidder number", "PIN"])

        var sendDetailsButton = blackButton(tag: .bidderDetailsButton, title: "Send me my details")
        sendDetailsButton.rx.action = requestBidderDetailsCommand(connectedToInternetOrStubbing())

        var conditionsButton = serifButton(tag: .conditionsOfSaleButton, title: "Conditions of Sale")
        conditionsButton.rx.action = showConditionsOfSaleCommand()

        buyersPremiumButton = serifButton(tag: .buyersPremiumButton, title: "Buyers Premium")
        buyersPremiumButton.rx.action = showBuyersPremiumCommand()

        var privacyButton = serifButton(tag: .privacyPolicyButton, title: "Privacy Policy")
        privacyButton.rx.action = showPrivacyPolicyCommand()

        // Add subviews
        view.addSubview(stackView)
        stackView.alignTop("0", leading: "0", bottom: nil, trailing: "0", to: view)
        stackView.addSubview(assistanceLabel, withTopMargin: "\(topMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(stuckExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(registerButton, withTopMargin: "20", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsLabel, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(bidderDetailsExplainLabel, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(sendDetailsButton, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(conditionsButton, withTopMargin: "\(headerMargin)", sideMargin: "\(sideMargin)")
        stackView.addSubview(privacyButton, withTopMargin: "\(inbetweenMargin)", sideMargin: "\(self.sideMargin)")

        hasBuyersPremium
            .subscribe(onNext: { [weak self] hasBuyersPremium in
                if hasBuyersPremium {
                    self?.stackView.addSubview(self!.buyersPremiumButton, withTopMargin: "\(self!.inbetweenMargin)", sideMargin: "\(self!.sideMargin)")
                } else {
                    self?.stackView.removeSubview(self!.buyersPremiumButton)
                }
            })
            .addDisposableTo(rx_disposeBag)
    }

    func blackButton(tag: SubviewTag, title: String) -> ARBlackFlatButton {
        let button = ARBlackFlatButton()
        button.setTitle(title, for: .normal)
        button.tag = tag.rawValue

        return button
    }

    func serifButton(tag: SubviewTag, title: String) -> ARUnderlineButton {
        let button = ARUnderlineButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.artsyGrayBold(), for: .normal)
        button.titleLabel?.font = UIFont.serifFont(withSize: 18)
        button.contentHorizontalAlignment = .left
        button.tag = tag.rawValue

        return button
    }

    func wrappingSerifLabel(tag: SubviewTag, text: String) -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.withSize(18)
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = CGFloat(HelpViewController.width - sideMargin)
        label.tag = tag.rawValue

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        label.attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle])

        return label
    }

    func titleLabel(tag: SubviewTag, title: String) -> ARSerifLabel {
        let label = ARSerifLabel()
        label.font = label.font.withSize(24)
        label.text = title
        label.tag = tag.rawValue
        return label
    }
}
