import UIKit

extension UILabel {
    func makeSubstringsBold(_ text: [String]) {
        text.forEach { self.makeSubstringBold($0) }
    }

    func makeSubstringBold(_ boldText: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString

        let range = ((self.text ?? "") as NSString).range(of: boldText)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifSemiBoldFont(withSize: self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func makeSubstringsItalic(_ text: [String]) {
        text.forEach { self.makeSubstringItalic($0) }
    }

    func makeSubstringItalic(_ italicText: String) {
        let attributedText = self.attributedText!.mutableCopy() as! NSMutableAttributedString

        let range = ((self.text ?? "") as NSString).range(of: italicText)
        if range.location != NSNotFound {
            attributedText.setAttributes([NSFontAttributeName: UIFont.serifItalicFont(withSize: self.font.pointSize)], range: range)
        }

        self.attributedText = attributedText
    }

    func setLineHeight(_ lineHeight: Int) {
        let displayText = text ?? ""
        let attributedString = self.attributedText!.mutableCopy() as! NSMutableAttributedString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineHeight)
        paragraphStyle.alignment = textAlignment
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, displayText.count))

        attributedText = attributedString
    }

    func makeTransparent() {
        isOpaque = false
        backgroundColor = .clear
    }
}
