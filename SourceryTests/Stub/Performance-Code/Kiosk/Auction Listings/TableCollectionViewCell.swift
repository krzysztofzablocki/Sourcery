import UIKit
import RxCocoa

class TableCollectionViewCell: ListingsCollectionViewCell {
    fileprivate lazy var infoView: UIView = {
        let view = UIView()
        view.addSubview(self.lotNumberLabel)
        view.addSubview(self.artistNameLabel)
        view.addSubview(self.artworkTitleLabel)

        self.lotNumberLabel.alignTop("0", bottom: nil, to: view)
        self.lotNumberLabel.alignLeading("0", trailing: "0", to: view)
        self.artistNameLabel.alignAttribute(.top, to: .bottom, of: self.lotNumberLabel, predicate: "5")
        self.artistNameLabel.alignLeading("0", trailing: "0", to: view)
        self.artworkTitleLabel.alignLeading("0", trailing: "0", to: view)
        self.artworkTitleLabel.alignAttribute(.top, to: .bottom, of: self.artistNameLabel, predicate: "0")
        self.artworkTitleLabel.alignTop(nil, bottom: "0", to: view)
        return view
    }()

    fileprivate lazy var cellSubviews: [UIView] = [self.artworkImageView, self.infoView, self.currentBidLabel, self.numberOfBidsLabel, self.bidButton]

    override func setup() {
        super.setup()

        contentView.constrainWidth("\(TableCollectionViewCell.Width)")

        // Configure subviews
        numberOfBidsLabel.textAlignment = .center
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.clipsToBounds = true

        // Add subviews
        cellSubviews.forEach { self.contentView.addSubview($0) }

        // Constrain subviews
        artworkImageView.alignAttribute(.width, to: .height, of: artworkImageView, predicate: nil)
        artworkImageView.alignTop("14", leading: "0", bottom: "-14", trailing: nil, to: contentView)
        artworkImageView.constrainHeight("56")

        infoView.alignAttribute(.left, to: .right, of: artworkImageView, predicate: "28")
        infoView.alignCenterY(with: artworkImageView, predicate: "0")
        infoView.constrainWidth("300")

        currentBidLabel.alignAttribute(.left, to: .right, of: infoView, predicate: "33")
        currentBidLabel.alignCenterY(with: artworkImageView, predicate: "0")
        currentBidLabel.constrainWidth("180")

        numberOfBidsLabel.alignAttribute(.left, to: .right, of: currentBidLabel, predicate: "33")
        numberOfBidsLabel.alignCenterY(with: artworkImageView, predicate: "0")
        numberOfBidsLabel.alignAttribute(.right, to: .left, of: bidButton, predicate: "-33")

        bidButton.alignBottom(nil, trailing: "0", to: contentView)
        bidButton.alignCenterY(with: artworkImageView, predicate: "0")
        bidButton.constrainWidth("127")

        // Replaces the observable defined in the superclass, normally used to emit taps to a "More Info" label, which we don't have.
        let recognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(recognizer)
        self.moreInfo = recognizer.rx.event.map { _ -> Date in
            return Date()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.drawBottomSolidBorder(with: .artsyGrayMedium())
    }
}

extension TableCollectionViewCell {
    fileprivate struct SharedDimensions {
        var width: CGFloat = 0
        var height: CGFloat = 84

        static var instance = SharedDimensions()
    }

    class var Width: CGFloat {
        get {
            return SharedDimensions.instance.width
        }
        set (newWidth) {
            SharedDimensions.instance.width = newWidth
        }
    }

    class var Height: CGFloat {
        return SharedDimensions.instance.height
    }
}
