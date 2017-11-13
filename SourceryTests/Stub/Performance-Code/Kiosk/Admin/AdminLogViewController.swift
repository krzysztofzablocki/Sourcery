import UIKit

class AdminLogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = try? NSString(contentsOf: logPath(), encoding: String.Encoding.ascii.rawValue) as String
    }

    @IBOutlet weak var textView: UITextView!
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func logPath() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return docs.appendingPathComponent("logger.txt")
    }

    @IBAction func scrollTapped(_ sender: AnyObject) {
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count - 1, 1))
    }
}
