import UIKit

class TextField: UITextField {

    var shouldAnimateStateChange: Bool = true
    var shouldChangeColorWhenEditing: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        borderStyle = .none
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.borderWidth = 1
        tintColor = .black
        font = UIFont.serifFont(withSize: self.font?.pointSize ?? 26)
        stateChangedAnimated(false)
        setupEvents()
    }

    func setupEvents () {
        addTarget(self, action: #selector(TextField.editingDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(TextField.editingDidFinish(_:)), for: .editingDidEnd)
    }

    func editingDidBegin (_ sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func editingDidFinish(_ sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func stateChangedAnimated(_ animated: Bool) {
        let newBorderColor = borderColorForState().cgColor
        if newBorderColor == layer.borderColor {
            return
        }
        if animated {
            let fade = CABasicAnimation()
            if layer.borderColor == nil { layer.borderColor = UIColor.clear.cgColor }
            fade.fromValue = self.layer.borderColor ?? UIColor.clear.cgColor
            fade.toValue = newBorderColor
            fade.duration = AnimationDuration.Short
            layer.add(fade, forKey: "borderColor")
        }
        layer.borderColor = newBorderColor
    }

    func borderColorForState() -> UIColor {
        if isEditing && shouldChangeColorWhenEditing {
            return .artsyPurpleRegular()
        } else {
            return .artsyGrayMedium()
        }
    }

    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0 )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0 )
    }
}

class SecureTextField: TextField {

    var actualText: String = ""

    override var text: String! {
        get {
            if isEditing {
                return super.text
            } else {
                return actualText
            }
        }

        set {
            super.text=(newValue)
        }
    }

    override func setup() {
        super.setup()
        clearsOnBeginEditing = true
    }

    override func setupEvents () {
        super.setupEvents()
        addTarget(self, action: #selector(SecureTextField.editingDidChange(_:)), for: .editingChanged)
    }

    override func editingDidBegin (_ sender: AnyObject) {
        super.editingDidBegin(sender)
        isSecureTextEntry = true
        actualText = text
    }

    func editingDidChange(_ sender: AnyObject) {
        actualText = text
    }

    override func editingDidFinish(_ sender: AnyObject) {
        super.editingDidFinish(sender)
        isSecureTextEntry = false
        actualText = text
        text = dotPlaceholder()
    }

    func dotPlaceholder() -> String {
        var index = 0
        let dots = NSMutableString()
        while (index < text.count) {
            dots.append("•")
            index += 1
        }
        return dots as String
    }
}
