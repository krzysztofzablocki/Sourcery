import UIKit

class AuctionWebViewController: WebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        let exitImage = UIImage(named: "toolbar_close")
        let backwardBarItem = UIBarButtonItem(image: exitImage, style: .plain, target: self, action: #selector(exit))
        let allItems = self.toolbarItems! + [flexibleSpace, backwardBarItem]
        toolbarItems = allItems
    }

    func exit() {
        let passwordVC = PasswordAlertViewController.alertView { [weak self] in
            _ = self?.navigationController?.popViewController(animated: true)
            return
        }
        self.present(passwordVC, animated: true) {}
    }
}
