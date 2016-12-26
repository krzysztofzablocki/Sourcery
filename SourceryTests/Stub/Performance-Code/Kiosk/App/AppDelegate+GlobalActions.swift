import UIKit
import QuartzCore
import ARAnalytics
import RxSwift
import Action

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

extension AppDelegate {

    // Registration

    var sale: Sale! {
        return appViewController!.sale.value
    }

    internal var appViewController: AppViewController! {
        let nav = self.window?.rootViewController?.findChildViewControllerOfType(UINavigationController.self) as? UINavigationController
        return nav?.delegate as? AppViewController
    }

    // Help button and menu

    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", for: .normal)
        helpButton.rx.action = helpButtonCommand()
        window?.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-24", trailing: "-24", to: window)
        window?.layoutIfNeeded()

        helpIsVisisble.subscribe(onNext: { visisble in
            let image: UIImage? = visisble ?  UIImage(named: "xbtn_white")?.withRenderingMode(.alwaysOriginal) : nil
            let text: String? = visisble ? nil : "HELP"

            self.helpButton.setTitle(text, for: .normal)
            self.helpButton.setImage(image, for: .normal)

            let transition = CATransition()
            transition.duration = AnimationDuration.Normal
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.helpButton.layer.add(transition, forKey: "fade")

        }).addDisposableTo(rx_disposeBag)
    }

    func setHelpButtonHidden(_ hidden: Bool) {
        helpButton.isHidden = hidden
    }
}

// MARK: - ReactiveCocoa extensions

fileprivate var retainedAction: CocoaAction?
extension AppDelegate {
    // In this extension, I'm omitting [weak self] because the app delegate will outlive everyone.

    func showBuyersPremiumCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThings()
                .then(self.showWebController(address: "https://m.artsy.net/auction/\(self.sale.id)/buyers-premium"))
                .map(void)
        }
    }

    func registerToBidCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThings()
                .then(self.showRegistration())
        }
    }

    func requestBidderDetailsCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideHelp()
                .then(self.showBidderDetailsRetrieval())
        }
    }

    func helpButtonCommand() -> CocoaAction {
        return CocoaAction { _ in
            let showHelp = self.hideAllTheThings().then(self.showHelp())

            return self.helpIsVisisble.take(1).flatMap { (visible: Bool) -> Observable<Void> in
                if visible {
                    return self.hideHelp()
                } else {
                    return showHelp
                }
            }
        }
    }

    /// This is a hack around the fact that the command might dismiss the view controller whose UI owns the command itself.
    /// So we store the CocoaAction in a variable private to this file to retain it. Once the action is complete, then we
    /// release our reference to the CocoaAction. This ensures that the action isn't cancelled while it's executing.
    func ensureAction(action: CocoaAction) -> CocoaAction {
        retainedAction = action
        let action = CocoaAction { input -> Observable<Void> in
            return retainedAction?
                .execute(input)
                .doOnCompleted {
                    retainedAction = nil
                } ?? Observable.just(Void())
        }

        return action
    }

    func showPrivacyPolicyCommand() -> CocoaAction {
        return ensureAction(action: CocoaAction { _ in
            self.hideAllTheThings().then(self.showWebController(address: "https://artsy.net/privacy"))
        })
    }

    func showConditionsOfSaleCommand() -> CocoaAction {
        return ensureAction(action: CocoaAction { _ in
            self.hideAllTheThings().then(self.showWebController(address: "https://artsy.net/conditions-of-sale"))
        })
    }
}

// MARK: - Private ReactiveCocoa Extension

private extension AppDelegate {

    // MARK: - s that do things

    func ツ() -> Observable<Void> {
        return hideAllTheThings()
    }

    func hideAllTheThings() -> Observable<Void> {
        return self.closeFulfillmentViewController().then(self.hideHelp())
    }

    func showBidderDetailsRetrieval() -> Observable<Void> {
        let appVC = self.appViewController
        let presentingViewController: UIViewController = (appVC!.presentedViewController ?? appVC!)
        return presentingViewController.promptForBidderDetailsRetrieval(provider: self.provider)
    }

    func showRegistration() -> Observable<Void> {
        return Observable.create { observer in
            ARAnalytics.event("Register To Bid Tapped")

            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as! FulfillmentContainerViewController
            containerController.allowAnimations = self.appViewController.allowAnimations

            if let internalNav: FulfillmentNavigationController = containerController.internalNavigationController() {
                internalNav.auctionID = self.appViewController.auctionID
                let registerVC = storyboard.viewController(withID: .RegisterAnAccount) as! RegisterViewController
                registerVC.placingBid = false
                registerVC.provider = self.provider
                internalNav.auctionID = self.appViewController.auctionID
                internalNav.viewControllers = [registerVC]
            }

            self.appViewController.present(containerController, animated: false) {
                containerController.viewDidAppearAnimation(containerController.allowAnimations)

                sendDispatchCompleted(to: observer)
            }

            return Disposables.create()
        }
    }

    func showHelp() -> Observable<Void> {
        return Observable.create { observer in
            let helpViewController = HelpViewController()
            helpViewController.modalPresentationStyle = .custom
            helpViewController.transitioningDelegate = self

            self.window?.rootViewController?.present(helpViewController, animated: true, completion: {
                self.helpViewController.value = helpViewController
                sendDispatchCompleted(to: observer)
            })

            return Disposables.create()
        }
    }

    func closeFulfillmentViewController() -> Observable<Void> {
        let close: Observable<Void> = Observable.create { observer in
            (self.appViewController.presentedViewController as? FulfillmentContainerViewController)?.closeFulfillmentModal() {
                sendDispatchCompleted(to: observer)
            }

            return Disposables.create()
        }

        return fullfilmentVisible.flatMap { visible -> Observable<Void> in
            if visible {
                return close
            } else {
                return .empty()
            }
        }

    }

    func showWebController(address: String) -> Observable<Void> {
        return hideWebViewController().then (
            Observable.create { observer in
                let webController = ModalWebViewController(url: NSURL(string: address)! as URL)

                let nav = UINavigationController(rootViewController: webController)
                nav.modalPresentationStyle = .formSheet

                ARAnalytics.event("Show Web View", withProperties: ["url" : address])
                self.window?.rootViewController?.present(nav, animated: true) {
                    sendDispatchCompleted(to: observer)
                }

                self.webViewController = nav

                return Disposables.create()
            }
        )
    }

    func hideHelp() -> Observable<Void> {
        return Observable.create { observer in
            if let presentingViewController = self.helpViewController.value?.presentingViewController {
                presentingViewController.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        observer.onCompleted()
                        self.helpViewController.value = nil
                    }
                    sendDispatchCompleted(to: observer)
                }
            } else {
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func hideWebViewController() -> Observable<Void> {
        return Observable.create { observer in
            if let webViewController = self.webViewController {
                webViewController.presentingViewController?.dismiss(animated: true) {
                    sendDispatchCompleted(to: observer)
                }
            } else {
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    // MARK: - Computed property observables

    var fullfilmentVisible: Observable<Bool> {
        return Observable.deferred {
            return Observable.create { observer in
                observer.onNext((self.appViewController.presentedViewController as? FulfillmentContainerViewController) != nil)
                observer.onCompleted()

                return Disposables.create()
            }
        }
    }

    var helpIsVisisble: Observable<Bool> {
        return helpViewController.asObservable().map { controller in
            return controller.hasValue
        }
    }
}

// MARK: - Help transtion animation

extension AppDelegate: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
