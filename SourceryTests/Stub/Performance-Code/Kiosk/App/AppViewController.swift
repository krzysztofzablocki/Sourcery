import UIKit
import RxSwift
import Action

class AppViewController: UIViewController, UINavigationControllerDelegate {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID

    @IBOutlet var countdownManager: ListingsCountdownManager!
    @IBOutlet var offlineBlockingView: UIView!
    @IBOutlet weak var registerToBidButton: ActionButton!

    var provider: Networking!

    lazy var _apiPinger: APIPingManager = {
        return APIPingManager(provider: self.provider)
    }()

    lazy var reachability: Observable<Bool> = {
        [connectedToInternetOrStubbing(), self.apiPinger].combineLatestAnd()
    }()

    lazy var apiPinger: Observable<Bool> = {
        self._apiPinger.letOnline
    }()

    var registerToBidCommand = { () -> CocoaAction in
        appDelegate().registerToBidCommand()
    }

    class func instantiate(from storyboard: UIStoryboard) -> AppViewController {
        return storyboard.viewController(withID: .AppViewController) as! AppViewController
    }

    var sale = Variable(Sale(id: "", name: "", isAuction: true, startDate: Date(), endDate: Date(), artworkCount: 0, state: ""))

    override func viewDidLoad() {
        super.viewDidLoad()

        registerToBidButton.rx.action = registerToBidCommand()

        countdownManager.setFonts()
        countdownManager.provider = provider

        reachability
            .bindTo(offlineBlockingView.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        auctionRequest(provider, auctionID: auctionID)
            .bindTo(sale)
            .addDisposableTo(rx_disposeBag)

        sale
            .asObservable()
            .mapToOptional()
            .bindTo(countdownManager.sale)
            .addDisposableTo(rx_disposeBag)

        for controller in childViewControllers {
            if let nav = controller as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // This is the embed segue
        guard let navigtionController = segue.destination as? UINavigationController else { return }
        guard let listingsViewController = navigtionController.topViewController as? ListingsViewController else { return }

        listingsViewController.provider = provider
    }

    deinit {
        countdownManager.invalidate()
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hide = (viewController as? SaleArtworkZoomViewController != nil)
        countdownManager.setLabelsHiddenIfSynced(hide)
        registerToBidButton.isHidden = hide
    }
}

extension AppViewController {

    @IBAction func longPressForAdmin(_ sender: UIGestureRecognizer) {
        if sender.state != .began {
            return
        }

        let passwordVC = PasswordAlertViewController.alertView { [weak self] in
            self?.performSegue(.ShowAdminOptions)
            return
        }
        self.present(passwordVC, animated: true) {}
    }

    func auctionRequest(_ provider: Networking, auctionID: String) -> Observable<Sale> {
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.auctionInfo(auctionID: auctionID)

        return provider.request(auctionEndpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(object: Sale.self)
            .logError()
            .retry()
            .throttle(1, scheduler: MainScheduler.instance)
    }
}
