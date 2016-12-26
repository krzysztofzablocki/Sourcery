import UIKit

class CursorView: UIView {

    let cursorLayer: CALayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        setupCursorLayer()
        startAnimating()
    }

    func setup() {
        layer.addSublayer(cursorLayer)
        setupCursorLayer()
    }

    func setupCursorLayer() {
        cursorLayer.frame = CGRect(x: layer.frame.width/2 - 1, y: 0, width: 2, height: layer.frame.height)
        cursorLayer.backgroundColor = UIColor.black.cgColor
        cursorLayer.opacity = 0.0
    }

    func startAnimating() {
        animate(Float.infinity)
    }

    fileprivate func animate(_ times: Float) {
        let fade = CABasicAnimation()
        fade.duration = 0.5
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fade.repeatCount = times
        fade.autoreverses = true
        fade.fromValue = 0.0
        fade.toValue = 1.0
        cursorLayer.add(fade, forKey: "opacity")
    }

    func stopAnimating() {
        cursorLayer.removeAllAnimations()
    }
}
