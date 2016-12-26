import UIKit

class FulfillmentContainerViewController: UIViewController {
    var allowAnimations = true

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var backgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        contentView.alpha = 0
        backgroundView.alpha = 0
        cancelButton.alpha = 0
    }

    // We force viewDidAppear to access the PlaceBidViewController
    // so this allow animations in the modal

    // This is mostly a placeholder for a more complex animation in the future

    func viewDidAppearAnimation(_ animated: Bool) {
        self.contentView.frame = self.contentView.frame.offsetBy(dx: 0, dy: 100)
        UIView.animateTwoStepIf(animated, duration: 0.3, {
            self.backgroundView.alpha = 1

        }, midway: {
            self.contentView.alpha = 1
            self.cancelButton.alpha = 1
            self.contentView.frame = self.contentView.frame.offsetBy(dx: 0, dy: -100)
        }) { (complete) in

        }
    }

    @IBAction func closeModalTapped(_ sender: AnyObject) {
        closeFulfillmentModal()
    }

    func closeFulfillmentModal(completion: (() -> ())? = nil) -> Void {
        UIView.animateIf(allowAnimations, duration: 0.4, {
            self.contentView.alpha = 0
            self.backgroundView.alpha = 0
            self.cancelButton.alpha = 0

            }) { (completed: Bool) in
                let presentingVC = self.presentingViewController!
                presentingVC.dismiss(animated: false, completion: nil)
                completion?()
        }
    }

    func internalNavigationController() -> FulfillmentNavigationController? {

        self.loadViewProgrammatically()
        return self.childViewControllers.first as? FulfillmentNavigationController
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> FulfillmentContainerViewController {
        return storyboard.viewController(withID: .FulfillmentContainer) as! FulfillmentContainerViewController
    }
}
