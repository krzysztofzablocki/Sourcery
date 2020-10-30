import AEXML
import Foundation

extension XCScheme {
    public final class BuildableProductRunnable: Runnable {
        // MARK: - XML

        override func xmlElement() -> AEXMLElement {
            let element = super.xmlElement()
            element.name = "BuildableProductRunnable"
            return element
        }
    }
}
