import UIKit
import ORStackView
import RxSwift

class RegisterFlowView: ORStackView {

    let highlightedIndex = Variable(0)

    lazy var appSetup: AppSetup = .sharedState

    var details: BidDetails? {
        didSet {
            update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .white
        bottomMarginHeight = CGFloat(NSNotFound)
        updateConstraints()
    }

    fileprivate struct SubViewParams {
        let title: String
        let getters: Array<(NewUser) -> String?>
    }

    fileprivate lazy var subViewParams: Array<SubViewParams> = {
        return [
            [SubViewParams(title: "Mobile", getters: [ { $0.phoneNumber.value }])],
            [SubViewParams(title: "Email", getters: [ { $0.email.value }])],
            [SubViewParams(title: "Postal/Zip", getters: [ { $0.zipCode.value }])].filter { _ in self.appSetup.needsZipCode },
            [SubViewParams(title: "Credit Card", getters: [ { $0.creditCardName.value }, { $0.creditCardType.value }])]
        ].flatMap {$0}
    }()

    func update() {
        let user = details!.newUser

        removeAllSubviews()
        for (i, subViewParam) in subViewParams.enumerated() {
            let itemView = ItemView(frame: bounds)
            itemView.createTitleViewWithTitle(subViewParam.title)

            addSubview(itemView, withTopMargin: "10", sideMargin: "0")

            if let value = (subViewParam.getters.flatMap { $0(user) }.first) {
                itemView.createInfoLabel(value)

                let button = itemView.createJumpToButtonAtIndex(i)
                button.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)

                itemView.constrainHeight("44")
            } else {
                itemView.constrainHeight("20")
            }

            if i == highlightedIndex.value {
                itemView.highlight()
            }
        }

        let spacer = UIView(frame: bounds)
        spacer.setContentHuggingPriority(12, for: .horizontal)
        addSubview(spacer, withTopMargin: "0", sideMargin: "0")

        bottomMarginHeight = 0
    }

    func pressed(_ sender: UIButton!) {
        highlightedIndex.value = sender.tag
    }

    class ItemView: UIView {

        var titleLabel: UILabel?

        func highlight() {
            titleLabel?.textColor = .artsyPurpleRegular()
        }

        func createTitleViewWithTitle(_ title: String) {
            let label = UILabel(frame: bounds)
            label.font = UIFont.sansSerifFont(withSize: 16)
            label.text = title.uppercased()
            titleLabel = label

            addSubview(label)
            label.constrainWidth(to: self, predicate: "0")
            label.alignLeadingEdge(with: self, predicate: "0")
            label.alignTopEdge(with: self, predicate: "0")
        }

        func createInfoLabel(_ info: String) {
            let label = UILabel(frame: bounds)
            label.font = UIFont.serifFont(withSize: 16)
            label.text = info

            addSubview(label)
            label.constrainWidth(to: self, predicate: "-52")
            label.alignLeadingEdge(with: self, predicate: "0")
            label.constrainTopSpace(to: titleLabel!, predicate: "8")
        }

        func createJumpToButtonAtIndex(_ index: NSInteger) -> UIButton {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setImage(UIImage(named: "edit_button"), for: .normal)
            button.isUserInteractionEnabled = true
            button.isEnabled = true

            addSubview(button)
            button.alignTopEdge(with: self, predicate: "0")
            button.alignTrailingEdge(with: self, predicate: "0")
            button.constrainWidth("36")
            button.constrainHeight("36")

            return button

        }
    }
}
