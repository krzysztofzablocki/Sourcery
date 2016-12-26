import UIKit

// Unused ATM

class ConfirmYourBidPasswordViewController: UIViewController {

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidPasswordViewController {
        return storyboard.viewController(withID: .ConfirmYourBid) as! ConfirmYourBidPasswordViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails
    }

    @IBAction func dev_noPhoneNumberFoundTapped(_ sender: AnyObject) {

    }

}
