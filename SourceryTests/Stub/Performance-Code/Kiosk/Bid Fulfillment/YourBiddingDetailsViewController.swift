import UIKit
import Artsy_UILabels
import Artsy_UIButtons
import RxCocoa
import RxSwift

class YourBiddingDetailsViewController: UIViewController {

    var provider: Networking!
    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!

    @IBOutlet weak var confirmationImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: ARSerifLabel!
    @IBOutlet weak var bodyLabel: ARSerifLabel!
    @IBOutlet weak var notificationLabel: ARSerifLabel!

    var confirmationImage: UIImage?

    lazy var bidDetails: BidDetails! = { (self.navigationController as! FulfillmentNavigationController).bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        [notificationLabel, bidderNumberLabel, pinNumberLabel].forEach { $0.makeTransparent() }
        notificationLabel.setLineHeight(5)
        bodyLabel.setLineHeight(10)

        if let image = confirmationImage {
            confirmationImageView.image = image
        }

        bodyLabel?.makeSubstringsBold(["Bidder Number", "PIN"])

        bidDetails
            .paddleNumber
            .asObservable()
            .filterNilKeepOptional()
            .bindTo(bidderNumberLabel.rx.text)
            .addDisposableTo(rx_disposeBag)

        bidDetails
            .bidderPIN
            .asObservable()
            .filterNilKeepOptional()
            .bindTo(pinNumberLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
    }

    @IBAction func confirmButtonTapped(_ sender: AnyObject) {
        fulfillmentContainer()?.closeFulfillmentModal()
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> YourBiddingDetailsViewController {
        return storyboard.viewController(withID: .YourBidderDetails) as! YourBiddingDetailsViewController
    }
}
