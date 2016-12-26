import Foundation
import RxSwift
import Keys

class AdminCardTestingViewController: UIViewController {

    lazy var keys = EidolonKeys()
    var cardHandler: CardHandler!

    @IBOutlet weak var logTextView: UITextView!

     override func viewDidLoad() {
        super.viewDidLoad()

        self.logTextView.text = ""

        if AppSetup.sharedState.useStaging {
            cardHandler = CardHandler(apiKey: self.keys.cardflightStagingAPIClientKey(), accountToken: self.keys.cardflightStagingMerchantAccountToken())
        } else {
            cardHandler = CardHandler(apiKey: self.keys.cardflightProductionAPIClientKey(), accountToken: self.keys.cardflightProductionMerchantAccountToken())
        }

        cardHandler.cardStatus
            .subscribe { (event) in
                switch event {
                case .next(let message):
                    self.log("\(message)")
                case .error(let error):
                    self.log("\n====Error====\n\(error)\nThe card reader may have become disconnected.\n\n")
                    if self.cardHandler.card != nil {
                        self.log("==\n\(self.cardHandler.card!)\n\n")
                    }
                case .completed:
                    guard let card = self.cardHandler.card else {
                        // Restarts the card reader
                        self.cardHandler.startSearching()
                        return
                    }

                    let cardDetails = "Card: \(card.name) - \(card.last4) \n \(card.cardToken)"
                    self.log(cardDetails)
                }
            }
            .addDisposableTo(rx_disposeBag)

        cardHandler.startSearching()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardHandler.end()
    }

    func log(_ string: String) {
        self.logTextView.text = "\(self.logTextView.text ?? "")\n\(string)"

    }

    @IBAction func backTapped(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
}
