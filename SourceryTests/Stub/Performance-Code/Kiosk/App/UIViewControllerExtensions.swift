import UIKit

extension UIViewController {

    /// Short hand syntax for loading the view controller 

    func loadViewProgrammatically() {
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    /// Short hand syntax for performing a segue with a known hardcoded identity

    func performSegue(_ identifier: SegueIdentifier) {
        self.performSegue(withIdentifier: identifier.rawValue, sender: self)
    }

    func fulfillmentNav() -> FulfillmentNavigationController {
        return (navigationController! as! FulfillmentNavigationController)
    }

    func fulfillmentContainer() -> FulfillmentContainerViewController? {
        return fulfillmentNav().parent as? FulfillmentContainerViewController
    }

    func findChildViewControllerOfType(_ klass: AnyClass) -> UIViewController? {
        for child in childViewControllers {
            if child.isKind(of: klass) {
                return child
            }
        }
        return nil
    }
}
