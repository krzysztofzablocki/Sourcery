import Foundation
import XNGMarkdownParser
import Artsy_UIFonts

class MarkdownParser: XNGMarkdownParser {

    override init() {
        super.init()

        paragraphFont = UIFont.serifFont(withSize: 16)
        linkFontName = UIFont.serifItalicFont(withSize: 16).fontName
        boldFontName = UIFont.serifBoldFont(withSize: 16).fontName
        italicFontName = UIFont.serifItalicFont(withSize: 16).fontName
        shouldParseLinks = false

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 16

        topAttributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.black
        ]
    }
}
