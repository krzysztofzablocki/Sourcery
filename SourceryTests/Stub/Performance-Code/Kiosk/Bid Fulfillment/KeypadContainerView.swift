import UIKit
import Foundation
import RxSwift
import Action
import FLKAutoLayout

//@IBDesignable
class KeypadContainerView: UIView {
    fileprivate var keypad: KeypadView!
    fileprivate let viewModel = KeypadViewModel()

    var stringValue: Observable<String>!
    var intValue: Observable<Int>!
    var deleteAction: CocoaAction!
    var resetAction: CocoaAction!

    override func prepareForInterfaceBuilder() {
        for subview in subviews { subview.removeFromSuperview() }

        let bundle = Bundle(for: type(of: self))
        let image  = UIImage(named: "KeypadViewPreviewIB", in: bundle, compatibleWith: self.traitCollection)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image

        self.addSubview(imageView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        keypad = Bundle(for: type(of: self)).loadNibNamed("KeypadView", owner: self, options: nil)?.first as? KeypadView
        keypad.leftAction = viewModel.deleteAction
        keypad.rightAction = viewModel.clearAction
        keypad.keyAction = viewModel.addDigitAction

        intValue = viewModel.intValue.asObservable()
        stringValue = viewModel.stringValue.asObservable()
        deleteAction = viewModel.deleteAction
        resetAction = viewModel.clearAction

        self.addSubview(keypad)

        keypad.align(to: self)
    }
}
