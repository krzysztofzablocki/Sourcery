import UIKit

class AppSetup {

    var auctionID = "los-angeles-modern-auctions-march-2015"
    lazy var useStaging = true
    lazy var showDebugButtons = false
    lazy var disableCardReader = false
    var isTesting = false

    class var sharedState: AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    init() {
        let defaults = UserDefaults.standard
        if let auction = defaults.string(forKey: "KioskAuctionID") {
            auctionID = auction
        }

        useStaging = defaults.bool(forKey: "KioskUseStaging")
        showDebugButtons = defaults.bool(forKey: "KioskShowDebugButtons")
        disableCardReader = defaults.bool(forKey: "KioskDisableCardReader")

        if let _ = NSClassFromString("XCTest") { isTesting = true }
    }

    var needsZipCode: Bool {
        // If we're swiping with the card reaer, we don't need to collect a zip code.
        return false
    }
}
