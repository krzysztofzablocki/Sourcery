import UIKit
import RxSwift
import Action

class KeypadView: UIView {
    var leftAction: CocoaAction? {
        didSet {
            self.leftButton.rx.action = leftAction
        }
    }
    var rightAction: CocoaAction? {
        didSet {
            self.rightButton.rx.action = rightAction
        }
    }

    var keyAction: Action<Int, Void>?

    @IBOutlet fileprivate var keys: [Button]!
    @IBOutlet fileprivate var leftButton: Button!
    @IBOutlet fileprivate var rightButton: Button!

    @IBAction func keypadButtonTapped(_ sender: UIButton) {
        keyAction?.execute(sender.tag)
    }
}
