import UIKit

class PasswordAlertViewController: UIAlertController {

    class func alertView(completion: @escaping () -> ()) -> PasswordAlertViewController {
        let alertController = PasswordAlertViewController(title: "Exit Kiosk", message: nil, preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "Exit", style: .default) { (_) in
            completion()
            return
        }

        if detectDevelopmentEnvironment() {
            exitAction.isEnabled = true
        } else {
            exitAction.isEnabled = false
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

        alertController.addTextField { (textField) in
            textField.placeholder = "Exit Password"

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                // compiler crashes when using weak
                exitAction.isEnabled = textField.text == "Genome401"
            }
        }

        alertController.addAction(exitAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
