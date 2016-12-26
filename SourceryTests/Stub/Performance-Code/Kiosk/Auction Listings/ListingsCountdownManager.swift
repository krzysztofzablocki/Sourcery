import UIKit
import RxSwift

class ListingsCountdownManager: NSObject {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var countdownContainerView: UIView!
    let formatter = NumberFormatter()

    let sale = Variable<Sale?>(nil)

    let time = SystemTime()
    var provider: Networking! {
        didSet {
            time.sync(provider)
                .dispatchAsyncMainScheduler()
                .take(1)
                .subscribe(onNext: { [weak self] (_) in
                    self?.startTimer()
                    self?.setLabelsHidden(false)
                })
                .addDisposableTo(rx_disposeBag)
        }
    }

    fileprivate var _timer: Timer? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        formatter.minimumIntegerDigits = 2
    }

    /// Immediately invalidates the timer. No further updates will be made to the UI after this method is called.
    func invalidate() {
        _timer?.invalidate()
    }

    func setFonts() {
        (countdownContainerView.subviews).forEach { (view) -> () in
            if let label = view as? UILabel {
                label.font = UIFont.serifFont(withSize: 15)
            }
        }
        countdownLabel.font = UIFont.sansSerifFont(withSize: 20)
    }

    func setLabelsHidden(_ hidden: Bool) {
        countdownContainerView.isHidden = hidden
    }

    func setLabelsHiddenIfSynced(_ hidden: Bool) {
        if time.inSync() {
            setLabelsHidden(hidden)
        }
    }

    func hideDenomenatorLabels() {
        for subview in countdownContainerView.subviews {
            subview.isHidden = subview != countdownLabel
        }
    }

    func startTimer() {
        let timer = Timer(timeInterval: 0.49, target: self, selector: #selector(ListingsCountdownManager.tick(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

        _timer = timer

        self.tick(timer)
    }

    func tick(_ timer: Timer) {
        guard let sale = sale.value else { return }
        guard time.inSync() else { return }
        guard sale.id != "" else { return }

        if sale.isActive(time) {
            let now = time.date()

            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: sale.endDate)

            self.countdownLabel.text = "\(formatter.string(from: (components.hour ?? 0) as NSNumber)!) : \(formatter.string(from: (components.minute ?? 0) as NSNumber)!) : \(formatter.string(from: (components.second ?? 0) as NSNumber)!)"

        } else {
            self.countdownLabel.text = "CLOSED"
            hideDenomenatorLabels()
            timer.invalidate()
            _timer = nil
        }
    }
}
