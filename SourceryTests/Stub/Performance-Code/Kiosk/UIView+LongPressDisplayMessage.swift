import UIKit
import RxSwift

private func alertController(_ message: String, title: String) -> UIAlertController {
    let alertController =  UIAlertController(title: title, message: message, preferredStyle: .alert)

    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    return alertController
}

extension UIView {
    typealias PresentAlertClosure = (_ alertController: UIAlertController) -> Void

    func presentOnLongPress(_ message: String, title: String, closure: @escaping PresentAlertClosure) {
        let recognizer = UILongPressGestureRecognizer()

        recognizer
            .rx.event
            .subscribe(onNext: { _ in
                closure(alertController(message, title: title))
            })
            .addDisposableTo(rx_disposeBag)

        isUserInteractionEnabled = true
        addGestureRecognizer(recognizer)
    }
}
