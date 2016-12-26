import UIKit
import RxSwift

class HelpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool

    init(presenting: Bool = false) {
        self.presenting = presenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationDuration.Normal
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let fromView: UIView! = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let toView: UIView! = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view

        if presenting {
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! HelpViewController

            let dismissTapGestureRecognizer = UITapGestureRecognizer()
            dismissTapGestureRecognizer
                .rx.event
                .subscribe(onNext: { [weak toView] sender in
                    let pointInContainer = sender.location(in: toView)
                    if toView?.point(inside: pointInContainer, with: nil) == false {
                        appDelegate().helpButtonCommand().execute()
                    }
                })
            .addDisposableTo(rx_disposeBag)
            toViewController.dismissTapGestureRecognizer = dismissTapGestureRecognizer
            containerView.addGestureRecognizer(dismissTapGestureRecognizer)

            fromView.isUserInteractionEnabled = false

            containerView.backgroundColor = .black

            containerView.addSubview(fromView)
            containerView.addSubview(toView)

            toView.alignTop("0", bottom: "0", to: containerView)
            toView.constrainWidth("\(HelpViewController.width)")
            toViewController.positionConstraints = toView.alignAttribute(.left, to: .right, of: containerView, predicate: "0") as? [NSLayoutConstraint]
            containerView.layoutIfNeeded()

            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                containerView.removeConstraints(toViewController.positionConstraints ?? [])
                toViewController.positionConstraints = toView.alignLeading(nil, trailing: "0", to: containerView) as? [NSLayoutConstraint]
                containerView.layoutIfNeeded()

                fromView.alpha = 0.5
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! HelpViewController

            if let dismissTapGestureRecognizer = fromViewController.dismissTapGestureRecognizer {
                containerView.removeGestureRecognizer(dismissTapGestureRecognizer)
            }

            toView.isUserInteractionEnabled = true

            containerView.addSubview(toView)
            containerView.addSubview(fromView)

            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                containerView.removeConstraints(fromViewController.positionConstraints ?? [])
                fromViewController.positionConstraints = fromView.alignAttribute(.left, to: .right, of: containerView, predicate: "0") as? [NSLayoutConstraint]
                containerView.layoutIfNeeded()

                toView.alpha = 1.0
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
                // This following line is to work around a bug in iOS 8 💩
                UIApplication.shared.keyWindow!.insertSubview(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view, at: 0)
            })
        }
    }
}
