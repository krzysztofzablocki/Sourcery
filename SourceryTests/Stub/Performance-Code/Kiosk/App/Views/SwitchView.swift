import UIKit
import RxSwift

let SwitchViewBorderWidth: CGFloat = 2

class SwitchView: UIView {

    fileprivate var _selectedIndex = Variable(0)

    var selectedIndex: Observable<Int> { return _selectedIndex.asObservable() }

    var shouldAnimate = true
    var animationDuration: TimeInterval = AnimationDuration.Short

    fileprivate let buttons: Array<UIButton>
    fileprivate let selectionIndicator: UIView
    fileprivate let topSelectionIndicator: UIView
    fileprivate let bottomSelectionIndicator: UIView

    fileprivate let topBar = CALayer()
    fileprivate let bottomBar = CALayer()

    var selectionConstraint: NSLayoutConstraint!

    init(buttonTitles: Array<String>) {
        buttons = buttonTitles.map { (buttonTitle: String) -> UIButton in
            let button = UIButton(type: .custom)

            button.setTitle(buttonTitle, for: .normal)
            button.setTitle(buttonTitle, for: .disabled)

            if let titleLabel = button.titleLabel {
                titleLabel.font = UIFont.sansSerifFont(withSize: 13)
                titleLabel.backgroundColor = .white
                titleLabel.isOpaque = true
            }

            button.backgroundColor = .white
            button.setTitleColor(.black, for: .disabled)
            button.setTitleColor(.black, for: .selected)
            button.setTitleColor(.artsyGrayMedium(), for: .normal)

            return button
        }
        selectionIndicator = UIView()
        topSelectionIndicator = UIView()
        bottomSelectionIndicator = UIView()

        super.init(frame: CGRect.zero)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var rect = CGRect(x: 0, y: 0, width: layer.bounds.width, height: SwitchViewBorderWidth)
        topBar.frame = rect
        rect.origin.y = layer.bounds.height - SwitchViewBorderWidth
        bottomBar.frame = rect
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(buttonTitles: [])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 46)
    }

    func selectedButton(_ button: UIButton!) {
        let index = buttons.index(of: button)!
        setSelectedIndex(index, animated: shouldAnimate)
    }

    subscript(index: Int) -> UIButton? {
        get {
            if index >= 0 && index < buttons.count {
                return buttons[index]
            }
            return nil
        }
    }
}

private extension SwitchView {
    func setup() {
        if let firstButton = buttons.first {
            firstButton.isEnabled = false
        }

        let widthPredicateMultiplier = "*\(widthMultiplier())"

        for i in 0 ..< buttons.count {
            let button = buttons[i]

            self.addSubview(button)
            button.addTarget(self, action: #selector(SwitchView.selectedButton(_:)), for: .touchUpInside)

            button.constrainWidth(to: self, predicate: widthPredicateMultiplier)

            if (i == 0) {
                button.alignLeadingEdge(with: self, predicate: nil)
            } else {
                button.constrainLeadingSpace(to: buttons[i-1], predicate: nil)
            }

            button.alignTop("\(SwitchViewBorderWidth)", bottom: "\(-SwitchViewBorderWidth)", to: self)
        }

        topBar.backgroundColor = UIColor.artsyGrayMedium().cgColor
        bottomBar.backgroundColor = UIColor.artsyGrayMedium().cgColor
        layer.addSublayer(topBar)
        layer.addSublayer(bottomBar)

        selectionIndicator.addSubview(topSelectionIndicator)
        selectionIndicator.addSubview(bottomSelectionIndicator)

        topSelectionIndicator.backgroundColor = .black
        bottomSelectionIndicator.backgroundColor = .black

        topSelectionIndicator.alignTop("0", leading: "0", bottom: nil, trailing: "0", to: selectionIndicator)
        bottomSelectionIndicator.alignTop(nil, leading: "0", bottom: "0", trailing: "0", to: selectionIndicator)

        topSelectionIndicator.constrainHeight("\(SwitchViewBorderWidth)")
        bottomSelectionIndicator.constrainHeight("\(SwitchViewBorderWidth)")

        addSubview(selectionIndicator)
        selectionIndicator.constrainWidth(to: self, predicate: widthPredicateMultiplier)
        selectionIndicator.alignTop("0", bottom: "0", to: self)

        selectionConstraint = selectionIndicator.alignLeadingEdge(with: self, predicate: nil).last! as! NSLayoutConstraint
    }

    func widthMultiplier() -> Float {
        return 1.0 / Float(buttons.count)
    }

    func setSelectedIndex(_ index: Int) {
        setSelectedIndex(index, animated: false)
    }

    func setSelectedIndex(_ index: Int, animated: Bool) {
        UIView.animateIf(shouldAnimate && animated, duration: animationDuration, options: .curveEaseOut) {
            let button = self.buttons[index]

            self.buttons.forEach { (button: UIButton) in
                button.isEnabled = true
            }

            button.isEnabled = false

            // Set the x-position of the selection indicator as a fraction of the total width of the switch view according to which button was pressed.
            let multiplier = CGFloat(index) / CGFloat(self.buttons.count)

            self.removeConstraint(self.selectionConstraint)
            // It's illegal to have a multiplier of zero, so if we're at index zero, we .just stick to the left side.
            if multiplier == 0 {
                self.selectionConstraint = self.selectionIndicator.alignLeadingEdge(with: self, predicate: nil).last! as! NSLayoutConstraint
            } else {
                self.selectionConstraint = NSLayoutConstraint(item: self.selectionIndicator, attribute: .left, relatedBy: .equal, toItem: self, attribute: .right, multiplier: multiplier, constant: 0)
            }
            self.addConstraint(self.selectionConstraint)
            self.layoutIfNeeded()
        }

        self._selectedIndex.value = index
    }
}
