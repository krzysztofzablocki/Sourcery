import UIKit
import SystemConfiguration
import ARAnalytics
import RxSwift
import ARCollectionViewMasonryLayout
import NSObject_Rx

let HorizontalMargins = 65
let VerticalMargins = 26
let MasonryCellIdentifier = "MasonryCell"
let TableCellIdentifier = "TableCell"

class ListingsViewController: UIViewController {
    var allowAnimations = true

    var downloadImage: ListingsCollectionViewCell.DownloadImageClosure = { (url, imageView) -> () in
        if let url = url {
            imageView.sd_setImage(with: url as URL!)
        } else {
            imageView.image = nil
        }
    }
    var cancelDownloadImage: ListingsCollectionViewCell.CancelDownloadImageClosure = { (imageView) -> () in
        imageView.sd_cancelCurrentImageLoad()
    }

    var provider: Networking!

    lazy var viewModel: ListingsViewModelType = {
        return ListingsViewModel(provider:
            self.provider,
            selectedIndex: self.switchView.selectedIndex,
            showDetails: applyUnowned(self, ListingsViewController.showDetails),
            presentModal: applyUnowned(self, ListingsViewController.presentModalForSaleArtwork)
        )
    }()

    var cellIdentifier = Variable(MasonryCellIdentifier)

    @IBOutlet var stagingFlag: UIImageView!
    @IBOutlet var loadingSpinner: Spinner!

    lazy var collectionView: UICollectionView = { return .listingsCollectionViewWithDelegateDatasource(self) }()

    lazy var switchView: SwitchView = {
        return SwitchView(buttonTitles: ListingsViewModel.SwitchValues.allSwitchValueNames())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up development environment.

        if AppSetup.sharedState.isTesting {
            stagingFlag.isHidden = true
        } else {
            if APIKeys.sharedKeys.stubResponses {
                stagingFlag.image = UIImage(named: "StubbingFlag")
            } else if detectDevelopmentEnvironment() {
                let flagImageName = AppSetup.sharedState.useStaging ? "StagingFlag" : "ProductionFlag"
                stagingFlag.image = UIImage(named: flagImageName)
            } else {
                stagingFlag.isHidden = AppSetup.sharedState.useStaging == false
            }
        }

        // Add subviews

        view.addSubview(switchView)
        view.insertSubview(collectionView, belowSubview: loadingSpinner)

        // Set up reactive bindings
        viewModel
            .showSpinner
            .not()
            .bindTo(loadingSpinner.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        // Map switch selection to cell reuse identifier.
        viewModel
            .gridSelected
            .map { gridSelected -> String in
                if gridSelected {
                    return MasonryCellIdentifier
                } else {
                    return TableCellIdentifier
                }
            }
            .bindTo(cellIdentifier)
            .addDisposableTo(rx_disposeBag)

        // Reload collection view when there is new content.
        viewModel
            .updatedContents
            .mapReplace(with: collectionView)
            .doOnNext { collectionView in
                collectionView.reloadData()
            }
            .dispatchAsyncMainScheduler()
            .subscribe(onNext: { [weak self] collectionView in
                // Make sure we're on screen and not in a test or something.
                guard let _ = self?.view.window else { return }

                // Need to dispatchAsyncMainScheduler, since the changes in the CV's model aren't imediate, so we may scroll to a cell that doesn't exist yet.
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            })
            .addDisposableTo(rx_disposeBag)

        // Respond to changes in layout, driven by switch selection.
        viewModel
            .gridSelected
            .map { [weak self] gridSelected -> UICollectionViewLayout in
                switch gridSelected {
                case true:
                    return ListingsViewController.masonryLayout()
                default:
                    return ListingsViewController.tableLayout(width: (self?.switchView.frame ?? CGRect.zero).width)
                }
            }
            .subscribe(onNext: { [weak self] layout in
                // Need to explicitly call animated: false and reload to avoid animation
                self?.collectionView.setCollectionViewLayout(layout, animated: false)
            })
            .addDisposableTo(rx_disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .ShowSaleArtworkDetails {
            let saleArtwork = sender as! SaleArtwork!
            let detailsViewController = segue.destination as! SaleArtworkDetailsViewController
            detailsViewController.saleArtwork = saleArtwork
            detailsViewController.provider = provider
            ARAnalytics.event("Show Artwork Details", withProperties: ["id": saleArtwork?.artwork.id])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        let switchHeightPredicate = "\(switchView.intrinsicContentSize.height)"

        switchView.constrainHeight(switchHeightPredicate)
        switchView.alignTop("\(64+VerticalMargins)", leading: "\(HorizontalMargins)", bottom: nil, trailing: "-\(HorizontalMargins)", to: view)
        collectionView.constrainTopSpace(to: switchView, predicate: "0")
        collectionView.alignTop(nil, leading: "0", bottom: "0", trailing: "0", to: view)
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 80, right: 0)
    }
}

extension ListingsViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ListingsViewController {
        return storyboard.viewController(withID: .AuctionListings) as! ListingsViewController
    }
}

// MARK: - Collection View

extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, ARCollectionViewMasonryLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSaleArtworks
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.value, for: indexPath)

        if let listingsCell = cell as? ListingsCollectionViewCell {

            listingsCell.downloadImage = downloadImage
            listingsCell.cancelDownloadImage = cancelDownloadImage

            listingsCell.setViewModel(viewModel.saleArtworkViewModel(atIndexPath: indexPath))

            let bid = listingsCell.bidPressed.takeUntil(listingsCell.preparingForReuse)
            let moreInfo = listingsCell.moreInfo.takeUntil(listingsCell.preparingForReuse)

            bid
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.presentModalForSaleArtwork(atIndexPath: indexPath)
                })
                .addDisposableTo(rx_disposeBag)

            moreInfo
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.showDetailsForSaleArtwork(atIndexPath: indexPath)
                })
                .addDisposableTo(rx_disposeBag)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAt indexPath: IndexPath!) -> CGFloat {
        let aspectRatio = viewModel.imageAspectRatioForSaleArtwork(atIndexPath: indexPath)
        let hasEstimate = viewModel.hasEstimateForSaleArtwork(atIndexPath: indexPath)
        return MasonryCollectionViewCell.heightForCellWithImageAspectRatio(aspectRatio, hasEstimate: hasEstimate)
    }
}

// MARK: Private Methods

private extension ListingsViewController {

    func showDetails(forSaleArtwork saleArtwork: SaleArtwork) {

        ARAnalytics.event("Artwork Details Tapped", withProperties: ["id": saleArtwork.artwork.id])
        self.performSegue(withIdentifier: SegueIdentifier.ShowSaleArtworkDetails.rawValue, sender: saleArtwork)
    }

    func presentModalForSaleArtwork(_ saleArtwork: SaleArtwork) {
        bid(auctionID: viewModel.auctionID, saleArtwork: saleArtwork, allowAnimations: self.allowAnimations, provider: provider)
    }

    // MARK: Class methods

    class func masonryLayout() -> ARCollectionViewMasonryLayout {
        let layout = ARCollectionViewMasonryLayout(direction: .vertical)
        layout?.itemMargins = CGSize(width: 65, height: 20)
        layout?.dimensionLength = CGFloat(MasonryCollectionViewCellWidth)
        layout?.rank = 3
        layout?.contentInset = UIEdgeInsetsMake(0.0, 0.0, CGFloat(VerticalMargins), 0.0)

        return layout!
    }

    class func tableLayout(width: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        TableCollectionViewCell.Width = width
        layout.itemSize = CGSize(width: width, height: TableCollectionViewCell.Height)
        layout.minimumLineSpacing = 0.0

        return layout
    }
}

// MARK: Collection view setup

extension UICollectionView {

    class func listingsCollectionViewWithDelegateDatasource(_ delegateDatasource: ListingsViewController) -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ListingsViewController.masonryLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = delegateDatasource
        collectionView.delegate = delegateDatasource
        collectionView.alwaysBounceVertical = true
        collectionView.register(MasonryCollectionViewCell.self, forCellWithReuseIdentifier: MasonryCellIdentifier)
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCellIdentifier)
        collectionView.allowsSelection = false
        return collectionView
    }
}
