import Foundation
import Artsy_UILabels
import RxSwift
import RxCocoa
import NSObject_Rx

class ListingsCollectionViewCell: UICollectionViewCell {
    typealias DownloadImageClosure = (_ url: URL?, _ imageView: UIImageView) -> ()
    typealias CancelDownloadImageClosure = (_ imageView: UIImageView) -> ()

    dynamic let lotNumberLabel = ListingsCollectionViewCell._sansSerifLabel()
    dynamic let artworkImageView = ListingsCollectionViewCell._artworkImageView()
    dynamic let artistNameLabel = ListingsCollectionViewCell._largeLabel()
    dynamic let artworkTitleLabel = ListingsCollectionViewCell._italicsLabel()
    dynamic let estimateLabel = ListingsCollectionViewCell._normalLabel()
    dynamic let currentBidLabel = ListingsCollectionViewCell._boldLabel()
    dynamic let numberOfBidsLabel = ListingsCollectionViewCell._rightAlignedNormalLabel()
    dynamic let bidButton = ListingsCollectionViewCell._bidButton()
    dynamic let moreInfoLabel = ListingsCollectionViewCell._infoLabel()

    var downloadImage: DownloadImageClosure?
    var cancelDownloadImage: CancelDownloadImageClosure?
    var reuseBag: DisposeBag?

    lazy var moreInfo: Observable<Date> = {
        return Observable.from([self.imageGestureSigal, self.infoGesture]).merge()
    }()

    fileprivate lazy var imageGestureSigal: Observable<Date> = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        self.artworkImageView.isUserInteractionEnabled = true
        return recognizer.rx.event.map { _ in Date() }
    }()

    fileprivate lazy var infoGesture: Observable<Date> = {
        let recognizer = UITapGestureRecognizer()
        self.moreInfoLabel.addGestureRecognizer(recognizer)
        self.moreInfoLabel.isUserInteractionEnabled = true
        return recognizer.rx.event.map { _ in Date() }
    }()

    fileprivate var _preparingForReuse = PublishSubject<Void>()

    var preparingForReuse: Observable<Void> {
        return _preparingForReuse.asObservable()
    }

    var viewModel = PublishSubject<SaleArtworkViewModel>()
    func setViewModel(_ newViewModel: SaleArtworkViewModel) {
        self.viewModel.onNext(newViewModel)
    }

    fileprivate var _bidPressed = PublishSubject<Date>()
    var bidPressed: Observable<Date> {
        return _bidPressed.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubscriptions()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubscriptions()
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadImage?(artworkImageView)
        _preparingForReuse.onNext()
        setupSubscriptions()
    }

    func setup() {
        // Necessary to use Autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupSubscriptions() {

        // Bind subviews
        reuseBag = DisposeBag()

        guard let reuseBag = reuseBag else { return }

        // Start with things not expected to ever change. 
        viewModel.flatMapTo(SaleArtworkViewModel.lotNumber)
            .replaceNil(with: "")
            .mapToOptional()
            .bindTo(lotNumberLabel.rx.text)
            .addDisposableTo(reuseBag)

        viewModel.map { (viewModel) -> URL? in
                return viewModel.thumbnailURL
            }.subscribe(onNext: { [weak self] url in
                guard let imageView = self?.artworkImageView else { return }
                self?.downloadImage?(url, imageView)
            }).addDisposableTo(reuseBag)

        viewModel.map { $0.artistName ?? "" }
            .bindTo(artistNameLabel.rx.text)
            .addDisposableTo(reuseBag)

        viewModel.map { $0.titleAndDateAttributedString }
            .mapToOptional()
            .bindTo(artworkTitleLabel.rx.attributedText)
            .addDisposableTo(reuseBag)

        viewModel.map { $0.estimateString }
            .bindTo(estimateLabel.rx.text)
            .addDisposableTo(reuseBag)

        // Now do properties that _do_ change.

        viewModel.flatMap { (viewModel) -> Observable<String> in
                return viewModel.currentBid(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ")
            }
            .mapToOptional()
            .bindTo(currentBidLabel.rx.text)
            .addDisposableTo(reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.numberOfBids)
            .mapToOptional()
            .bindTo(numberOfBidsLabel.rx.text)
            .addDisposableTo(reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.forSale)
            .doOnNext { [weak bidButton] forSale in
                // Button titles aren't KVO-able
                bidButton?.setTitle((forSale ? "BID" : "SOLD"), for: .normal)
            }
            .bindTo(bidButton.rx.isEnabled)
            .addDisposableTo(reuseBag)

        bidButton.rx.tap.subscribe(onNext: { [weak self] in
                self?._bidPressed.onNext(Date())
            })
            .addDisposableTo(reuseBag)
    }
}

private extension ListingsCollectionViewCell {

    // Mark: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .artsyGrayLight()
        return imageView
    }

    class func _rightAlignedNormalLabel() -> UILabel {
        let label = _normalLabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }

    class func _normalLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 1
        return label
    }

    class func _sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.font = label.font.withSize(12)
        label.numberOfLines = 1
        return label
    }

    class func _italicsLabel() -> UILabel {
        let label = ARItalicsSerifLabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 1
        return label
    }

    class func _largeLabel() -> UILabel {
        let label = _normalLabel()
        label.font = label.font.withSize(20)
        return label
    }

    class func _bidButton() -> ActionButton {
        let button = ActionButton()
        button.setTitle("BID", for: .normal)
        return button
    }

    class func _boldLabel() -> UILabel {
        let label = _normalLabel()
        label.font = UIFont.serifBoldFont(withSize: label.font.pointSize)
        label.numberOfLines = 1
        return label
    }

    class func _infoLabel() -> UILabel {
        let label = ARSansSerifLabelWithChevron()
        label.tintColor = .black
        label.text = "MORE INFO"
        return label
    }
}
