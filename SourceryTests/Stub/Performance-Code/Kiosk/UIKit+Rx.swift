import UIKit
import RxSwift
import RxCocoa

extension UIView {
    public var rx_hidden: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .next(let value):
                self?.isHidden = value
            case .error(let error):
                bindingErrorToInterface(error)
                break
            case .completed:
                break
            }
        }
    }
}

extension UITextField {
    var rx_returnKey: Observable<Void> {
        return self.rx.controlEvent(.editingDidEndOnExit).takeUntil(rx.deallocated)
    }
}
