import Foundation
import ARTiledImageView

class SaleArtworkZoomViewController: UIViewController {
    var dataSource: TiledImageDataSourceWithImage!
    var saleArtwork: SaleArtwork!
    var tiledImageView: ARTiledImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let image = saleArtwork.artwork.defaultImage!
        dataSource = TiledImageDataSourceWithImage(image:image)

        let tiledView = ARTiledImageScrollView(frame:view.bounds)
        tiledView.decelerationRate = UIScrollViewDecelerationRateFast
        tiledView.showsHorizontalScrollIndicator = false
        tiledView.showsVerticalScrollIndicator = false
        tiledView.contentMode = .scaleAspectFit
        tiledView.dataSource = dataSource
        tiledView.backgroundImageURL = image.fullsizeURL() as URL!

        view.insertSubview(tiledView, at:0)
        tiledImageView = tiledView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tiledImageView.zoom(toFit: false)
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
