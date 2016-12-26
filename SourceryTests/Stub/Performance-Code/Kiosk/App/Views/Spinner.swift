import UIKit

class Spinner: UIView {
    var spinner: UIView!
    let rotationDuration = 0.9

    func createSpinner() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
        view.backgroundColor = .black
        return view
    }

    override func awakeFromNib() {
        spinner = createSpinner()
        addSubview(spinner)
        backgroundColor = .clear
        animateN(Float.infinity)
    }

    override func layoutSubviews() {
        // .center uses frame
        spinner.center = CGPoint( x: bounds.width / 2, y: bounds.height / 2)
    }

    func animateN(_ times: Float) {
        let transformOffset = -1.01 * M_PI
        let transform = CATransform3DMakeRotation( CGFloat(transformOffset), 0, 0, 1)
        let rotationAnimation = CABasicAnimation(keyPath:"transform")

        rotationAnimation.toValue = NSValue(caTransform3D:transform)
        rotationAnimation.duration = rotationDuration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(times)
        layer.add(rotationAnimation, forKey:"spin")
    }

    func animate(_ animate: Bool) {
        let isAnimating = layer.animation(forKey: "spin") != nil
        if (isAnimating && !animate) {
            layer.removeAllAnimations()

        } else if (!isAnimating && animate) {
            self.animateN(Float.infinity)
        }
    }

    func stopAnimating() {
        layer.removeAllAnimations()
        animateN(1)
    }
}
