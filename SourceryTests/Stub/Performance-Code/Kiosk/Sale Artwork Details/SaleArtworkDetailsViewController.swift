import UIKit
import ORStackView
import Artsy_UILabels
import Artsy_UIFonts
import RxSwift
import Artsy_UIButtons
import SDWebImage
import Action

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var saleArtwork: SaleArtwork!
    var provider: Networking!

    var showBuyersPremiumCommand = { () -> CocoaAction in
        appDelegate().showBuyersPremiumCommand()
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> SaleArtworkDetailsViewController {
        return storyboard.viewController(withID: .SaleArtworkDetail) as! SaleArtworkDetailsViewController
    }

    lazy var artistInfo: Observable<Any> = {
        let artistInfo = self.provider.request(.artwork(id: self.saleArtwork.artwork.id)).filterSuccessfulStatusCodes().mapJSON()
        return artistInfo.shareReplay(1)
    }()

    @IBOutlet weak var metadataStackView: ORTagBasedAutoStackView!
    @IBOutlet weak var additionalDetailScrollView: ORStackScrollView!

    var buyersPremium: () -> (BuyersPremium?) = { appDelegate().sale.buyersPremium }
    let layoutSubviews = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMetadataView()
        setupAdditionalDetailStackView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // OK, so this is pretty weird, eh? So basically we need to be notified of layout changes _just after_ the layout
        // is actually done. For whatever reason, the UIKit hack to get the labels to adhere to their proper width only
        // works if we defer recalculating their geometry to the next runloop.
        // This wasn't an issue with RAC's rac_signalForSelector because that invoked the signal _after_ this method completed.
        // So that's what I've done here.
        DispatchQueue.main.async {
            self.layoutSubviews.onNext()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewWillAppear.onCompleted()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .ZoomIntoArtwork {
            let nextViewController = segue.destination as! SaleArtworkZoomViewController
            nextViewController.saleArtwork = saleArtwork
        }
    }

    enum MetadataStackViewTag: Int {
        case lotNumberLabel = 1
        case artistNameLabel
        case artworkNameLabel
        case artworkMediumLabel
        case artworkDimensionsLabel
        case imageRightsLabel
        case estimateTopBorder
        case estimateLabel
        case estimateBottomBorder
        case currentBidLabel
        case currentBidValueLabel
        case numberOfBidsPlacedLabel
        case bidButton
        case buyersPremium
    }

    @IBAction func backWasPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }

    fileprivate func setupMetadataView() {
        enum LabelType {
            case serif
            case sansSerif
            case italicsSerif
            case bold
        }

        func label(_ type: LabelType, tag: MetadataStackViewTag, fontSize: CGFloat = 16.0) -> UILabel {
            let label: UILabel = { () -> UILabel in
                switch type {
                case .serif:
                    return ARSerifLabel()
                case .sansSerif:
                    return ARSansSerifLabel()
                case .italicsSerif:
                    return ARItalicsSerifLabel()
                case .bold:
                    let label = ARSerifLabel()
                    label.font = UIFont.sansSerifFont(withSize: label.font.pointSize)
                    return label
                }
            }()

            label.lineBreakMode = .byWordWrapping
            label.font = label.font.withSize(fontSize)
            label.tag = tag.rawValue
            label.preferredMaxLayoutWidth = 276

            return label
        }

        let hasLotNumber = (saleArtwork.lotNumber != nil)

        if let _ = saleArtwork.lotNumber {
            let lotNumberLabel = label(.sansSerif, tag: .lotNumberLabel)
            lotNumberLabel.font = lotNumberLabel.font.withSize(12)
            metadataStackView.addSubview(lotNumberLabel, withTopMargin: "0", sideMargin: "0")

            saleArtwork
                .viewModel
                .lotNumber()
                .filterNil()
                .mapToOptional()
                .bindTo(lotNumberLabel.rx.text)
                .addDisposableTo(rx_disposeBag)
        }

        if let artist = artist() {
            let artistNameLabel = label(.sansSerif, tag: .artistNameLabel)
            artistNameLabel.text = artist.name
            metadataStackView.addSubview(artistNameLabel, withTopMargin: hasLotNumber ? "10" : "0", sideMargin: "0")
        }

        let artworkNameLabel = label(.italicsSerif, tag: .artworkNameLabel)
        artworkNameLabel.text = "\(saleArtwork.artwork.title), \(saleArtwork.artwork.date)"
        metadataStackView.addSubview(artworkNameLabel, withTopMargin: "10", sideMargin: "0")

        if let medium = saleArtwork.artwork.medium {
            if medium.isNotEmpty {
                let mediumLabel = label(.serif, tag: .artworkMediumLabel)
                mediumLabel.text = medium
                metadataStackView.addSubview(mediumLabel, withTopMargin: "22", sideMargin: "0")
            }
        }

        if saleArtwork.artwork.dimensions.count > 0 {
            let dimensionsLabel = label(.serif, tag: .artworkDimensionsLabel)
            dimensionsLabel.text = (saleArtwork.artwork.dimensions as NSArray).componentsJoined(by: "\n")
            metadataStackView.addSubview(dimensionsLabel, withTopMargin: "5", sideMargin: "0")
        }

        retrieveImageRights()
            .filter { imageRights -> Bool in
                return imageRights.isNotEmpty
            }.subscribe(onNext: { [weak self] imageRights in
                let rightsLabel = label(.serif, tag: .imageRightsLabel)
                rightsLabel.text = imageRights
                self?.metadataStackView.addSubview(rightsLabel, withTopMargin: "22", sideMargin: "0")
            })
            .addDisposableTo(rx_disposeBag)

        let estimateTopBorder = UIView()
        estimateTopBorder.constrainHeight("1")
        estimateTopBorder.tag = MetadataStackViewTag.estimateTopBorder.rawValue
        metadataStackView.addSubview(estimateTopBorder, withTopMargin: "22", sideMargin: "0")

        var estimateBottomBorder: UIView?

        let estimateString = saleArtwork.viewModel.estimateString
        if estimateString.isNotEmpty {
            let estimateLabel = label(.serif, tag: .estimateLabel)
            estimateLabel.text = estimateString
            metadataStackView.addSubview(estimateLabel, withTopMargin: "15", sideMargin: "0")

            estimateBottomBorder = UIView()
            _ = estimateBottomBorder?.constrainHeight("1")
            estimateBottomBorder?.tag = MetadataStackViewTag.estimateBottomBorder.rawValue
            metadataStackView.addSubview(estimateBottomBorder, withTopMargin: "10", sideMargin: "0")
        }

        viewWillAppear
            .subscribe(onCompleted: { [weak estimateTopBorder, weak estimateBottomBorder] in
                estimateTopBorder?.drawDottedBorders()
                estimateBottomBorder?.drawDottedBorders()
            })
            .addDisposableTo(rx_disposeBag)

        let hasBids = saleArtwork
            .rx.observe(NSNumber.self, "highestBidCents")
            .map { observeredCents -> Bool in
                guard let cents = observeredCents else { return false }
                return (cents as Int) > 0
            }

        let currentBidLabel = label(.serif, tag: .currentBidLabel)

        hasBids
            .flatMap { hasBids -> Observable<String> in
                if hasBids {
                    return .just("Current Bid:")
                } else {
                    return .just("Starting Bid:")
                }
            }
            .mapToOptional()
            .bindTo(currentBidLabel.rx.text)
            .addDisposableTo(rx_disposeBag)

        metadataStackView.addSubview(currentBidLabel, withTopMargin: "22", sideMargin: "0")

        let currentBidValueLabel = label(.bold, tag: .currentBidValueLabel, fontSize: 27)
        saleArtwork
            .viewModel
            .currentBid()
            .mapToOptional()
            .bindTo(currentBidValueLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        metadataStackView.addSubview(currentBidValueLabel, withTopMargin: "10", sideMargin: "0")

        let numberOfBidsPlacedLabel = label(.serif, tag: .numberOfBidsPlacedLabel)
        saleArtwork
            .viewModel
            .numberOfBidsWithReserve
            .mapToOptional()
            .bindTo(numberOfBidsPlacedLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        metadataStackView.addSubview(numberOfBidsPlacedLabel, withTopMargin: "10", sideMargin: "0")

        let bidButton = ActionButton()
        bidButton
            .rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let me = self else { return }

                me.bid(auctionID: me.auctionID, saleArtwork: me.saleArtwork, allowAnimations: me.allowAnimations, provider: me.provider)
            })
            .addDisposableTo(rx_disposeBag)

        saleArtwork
            .viewModel
            .forSale()
            .subscribe(onNext: { [weak bidButton] forSale in
                let forSale = forSale

                let title = forSale ? "BID" : "SOLD"
                bidButton?.setTitle(title, for: .normal)
            })
            .addDisposableTo(rx_disposeBag)

        saleArtwork
            .viewModel
            .forSale()
            .bindTo(bidButton.rx.isEnabled)
            .addDisposableTo(rx_disposeBag)

        bidButton.tag = MetadataStackViewTag.bidButton.rawValue
        metadataStackView.addSubview(bidButton, withTopMargin: "40", sideMargin: "0")

        if let _ = buyersPremium() {
            let buyersPremiumView = UIView()
            buyersPremiumView.tag = MetadataStackViewTag.buyersPremium.rawValue

            let buyersPremiumLabel = ARSerifLabel()
            buyersPremiumLabel.font = buyersPremiumLabel.font.withSize(16)
            buyersPremiumLabel.text = "This work has a "
            buyersPremiumLabel.textColor = .artsyGrayBold()

            var buyersPremiumButton = ARButton()
            let title = "buyers premium"
            let attributes: [String: AnyObject] = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject, NSFontAttributeName: buyersPremiumLabel.font ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            buyersPremiumButton.setTitle(title, for: .normal)
            buyersPremiumButton.titleLabel?.attributedText = attributedTitle
            buyersPremiumButton.setTitleColor(.artsyGrayBold(), for: .normal)

            buyersPremiumButton.rx.action = showBuyersPremiumCommand()

            buyersPremiumView.addSubview(buyersPremiumLabel)
            buyersPremiumView.addSubview(buyersPremiumButton)

            buyersPremiumLabel.alignTop("0", leading: "0", bottom: "0", trailing: nil, to: buyersPremiumView)
            buyersPremiumLabel.alignBaseline(with: buyersPremiumButton, predicate: nil)
            buyersPremiumButton.alignAttribute(.left, to: .right, of: buyersPremiumLabel, predicate: "0")

            metadataStackView.addSubview(buyersPremiumView, withTopMargin: "30", sideMargin: "0")
        }

        metadataStackView.bottomMarginHeight = CGFloat(NSNotFound)
    }

    fileprivate func setupImageView(_ imageView: UIImageView) {
        if let image = saleArtwork.artwork.defaultImage {

            // We'll try to retrieve the thumbnail image from the cache. If we don't have it, we'll set the background colour to grey to indicate that we're downloading it.
            let key = SDWebImageManager.shared().cacheKey(for: image.thumbnailURL() as URL!)
            let thumbnailImage = SDImageCache.shared().imageFromDiskCache(forKey: key)
            if thumbnailImage == nil {
                imageView.backgroundColor = .artsyGrayLight()
            }

            imageView.sd_setImage(with: image.fullsizeURL(), placeholderImage: thumbnailImage, options: [], completed: { (image, _, _, _) in
                // If the image was successfully downloaded, make sure we aren't still displaying grey.
                if image != nil {
                    imageView.backgroundColor = .clear
                }
            })

            let heightConstraintNumber = { () -> CGFloat in
                if let aspectRatio = image.aspectRatio {
                    if aspectRatio != 0 {
                        return min(400, CGFloat(538) / aspectRatio)
                    }
                }
                return 400
            }()
            imageView.constrainHeight( "\(heightConstraintNumber)" )

            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true

            let recognizer = UITapGestureRecognizer()
            imageView.addGestureRecognizer(recognizer)
            recognizer
                .rx.event
                .asObservable()
                .subscribe(onNext: { [weak self] _ in
                     self?.performSegue(.ZoomIntoArtwork)
                })
                .addDisposableTo(rx_disposeBag)
        }
    }

    fileprivate func setupAdditionalDetailStackView() {
        enum LabelType {
            case header
            case body
        }

        func label(_ type: LabelType, layout: Observable<Void>? = nil) -> UILabel {
            let (label, fontSize) = { () -> (UILabel, CGFloat) in
                switch type {
                case .header:
                    return (ARSansSerifLabel(), 14)
                case .body:
                    return (ARSerifLabel(), 16)
                }
            }()

            label.font = label.font.withSize(fontSize)
            label.lineBreakMode = .byWordWrapping

            layout?
                .take(1)
                .subscribe(onNext: { [weak label] (_) in
                    if let label = label {
                        label.preferredMaxLayoutWidth = label.frame.width
                    }
                })
                .addDisposableTo(rx_disposeBag)

            return label
        }

        additionalDetailScrollView.stackView.bottomMarginHeight = 40

        let imageView = UIImageView()
        additionalDetailScrollView.stackView.addSubview(imageView, withTopMargin: "0", sideMargin: "40")
        setupImageView(imageView)

        let additionalInfoHeaderLabel = label(.header)
        additionalInfoHeaderLabel.text = "Additional Information"
        additionalDetailScrollView.stackView.addSubview(additionalInfoHeaderLabel, withTopMargin: "20", sideMargin: "40")

        if let blurb = saleArtwork.artwork.blurb {
            let blurbLabel = label(.body, layout: layoutSubviews)
            blurbLabel.attributedText = MarkdownParser().attributedString( fromMarkdownString: blurb )
            additionalDetailScrollView.stackView.addSubview(blurbLabel, withTopMargin: "22", sideMargin: "40")
        }

        let additionalInfoLabel = label(.body, layout: layoutSubviews)
        additionalInfoLabel.attributedText = MarkdownParser().attributedString( fromMarkdownString: saleArtwork.artwork.additionalInfo )
        additionalDetailScrollView.stackView.addSubview(additionalInfoLabel, withTopMargin: "22", sideMargin: "40")

        retrieveAdditionalInfo()
            .filter { info in
                return info.isNotEmpty
            }.subscribe(onNext: { [weak self] info in
                additionalInfoLabel.attributedText = MarkdownParser().attributedString(fromMarkdownString: info)
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            })
            .addDisposableTo(rx_disposeBag)

        if let artist = artist() {
            retrieveArtistBlurb()
                .filter { blurb in
                    return blurb.isNotEmpty
                }
                .subscribe(onNext: { [weak self] blurb in
                    guard let me = self else { return }

                    let aboutArtistHeaderLabel = label(.header)
                    aboutArtistHeaderLabel.text = "About \(artist.name)"
                    me.additionalDetailScrollView.stackView.addSubview(aboutArtistHeaderLabel, withTopMargin: "22", sideMargin: "40")

                    let aboutAristLabel = label(.body, layout: me.layoutSubviews)
                    aboutAristLabel.attributedText = MarkdownParser().attributedString(fromMarkdownString: blurb)
                    me.additionalDetailScrollView.stackView.addSubview(aboutAristLabel, withTopMargin: "22", sideMargin: "40")
                })
                .addDisposableTo(rx_disposeBag)
        }
    }

    fileprivate func artist() -> Artist? {
        return saleArtwork.artwork.artists?.first
    }

    fileprivate func retrieveImageRights() -> Observable<String> {
        let artwork = saleArtwork.artwork

        if let imageRights = artwork.imageRights {
            return .just(imageRights)

        } else {
            return artistInfo.map { json in
                    return (json as AnyObject)["image_rights"] as? String
                }
                .filterNil()
                .doOnNext { imageRights in
                    artwork.imageRights = imageRights
                }
        }
    }

    fileprivate func retrieveAdditionalInfo() -> Observable<String> {
        let artwork = saleArtwork.artwork

        if let additionalInfo = artwork.additionalInfo {
            return .just(additionalInfo)
        } else {
            return artistInfo.map { json in
                    return (json as AnyObject)["additional_information"] as? String
                }
                .filterNil()
                .doOnNext { info in
                    artwork.additionalInfo = info
                }
        }
    }

    fileprivate func retrieveArtistBlurb() -> Observable<String> {
        guard let artist = artist() else {
            return .empty()
        }

        if let blurb = artist.blurb {
            return .just(blurb)
        } else {
            let retrieveArtist = provider.request(.artist(id: artist.id))
                .filterSuccessfulStatusCodes()
                .mapJSON()

            return retrieveArtist.map { json in
                    return (json as AnyObject)["blurb"] as? String
                }
                .filterNil()
                .doOnNext { blurb in
                    artist.blurb = blurb
                }
        }
    }
}
