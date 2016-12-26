import UIKit
import RxSwift
import SVProgressHUD
import Action

extension UIViewController {
    func promptForBidderDetailsRetrieval(provider: Networking) -> Observable<Void> {
        return Observable.deferred { () -> Observable<Void> in
            let alertController = self.emailPromptAlertController(provider: provider)

            self.present(alertController, animated: true) { }

            return .empty()
        }
    }

    func retrieveBidderDetails(provider: Networking, email: String) -> Observable<Void> {
        return Observable.just(email)
            .take(1)
            .doOnNext { _ in
                SVProgressHUD.show()
            }
            .flatMap { email -> Observable<Void> in
                let endpoint = ArtsyAPI.bidderDetailsNotification(auctionID: appDelegate().appViewController.sale.value.id, identifier: email)

                return provider.request(endpoint).filterSuccessfulStatusCodes().map(void)
            }
            .throttle(1, scheduler: MainScheduler.instance)
            .doOnNext { _ in
                SVProgressHUD.dismiss()
                self.present(UIAlertController.successfulBidderDetailsAlertController(), animated: true, completion: nil)
            }
            .doOnError { _ in
                SVProgressHUD.dismiss()
                self.present(UIAlertController.failedBidderDetailsAlertController(), animated: true, completion: nil)
            }
    }

    func emailPromptAlertController(provider: Networking) -> UIAlertController {
        let alertController = UIAlertController(title: "Send Bidder Details", message: "Enter your email address or phone number registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .alert)

        var ok = UIAlertAction.Action("OK", style: .default)
        let action = CocoaAction { _ -> Observable<Void> in
            let text = (alertController.textFields?.first)?.text ?? ""

            return self.retrieveBidderDetails(provider: provider, email: text)
        }
        ok.rx.action = action
        let cancel = UIAlertAction.Action("Cancel", style: .cancel)

        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)

        return alertController
    }
}

extension UIAlertController {
    class func successfulBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Your details have been sent", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.Action("OK", style: .default))

        return alertController
    }

    class func failedBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Incorrect Email", message: "Email was not recognized. You may not be registered to bid yet.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.Action("Cancel", style: .cancel))

        var retryAction = UIAlertAction.Action("Retry", style: .default)
        retryAction.rx.action = appDelegate().requestBidderDetailsCommand()

        alertController.addAction(retryAction)

        return alertController
    }
}
