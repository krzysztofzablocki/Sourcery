import Foundation

final class Localized: NSObject {
    fileprivate override init() {}
}

extension Localized {
    static func storeEnterRecipientNickname() -> String {
        return NSLocalizedString("Please enter the recipient's nickname", comment: "")
    }
    static func storeNameCannotBeEmpty() -> String {
        return NSLocalizedString("Sorry, the name can't be empty. Please enter a nickname to send the gift to. You can also send the gift to yourself!", comment: "")
    }
    static func storeSendGiftToUser() -> String {
        return NSLocalizedString("Send a gift to ", comment: "")
    }
    static func storeSendStickerPackToUser() -> String {
        return NSLocalizedString("Send Free Sticker Pack to ", comment: "label")
    }
    static func storeBuyStickerPackForUser() -> String {
        return NSLocalizedString("Buy Sticker Pack for ", comment: "label")
    }
    static func storeAddFreeStickerPackToUser() -> String {
        return NSLocalizedString("Add Free Sticker Pack to ", comment: "button")
    }
    static func storeAddFreeStickerPack() -> String {
        return NSLocalizedString("Add Free Sticker Pack", comment: "button")
    }
    static func storeNoUserWithNickname() -> String {
        return NSLocalizedString("No user exists with that nickname", comment: "")
    }
    static func storeWhosThisGiftGoigTo() -> String {
        return NSLocalizedString("Who's this gift going to?", comment:"")
    }
    static func profileGiftFrom(_ nick: String) -> String {
        return NSLocalizedString("Gift from %@", comment: "label")
    }
    static func profileGiftFromAnonymous() -> String {
        return NSLocalizedString("Gift from Anonymous", comment: "label")
    }
    static func profileInvisibleModeAlert() -> String {
        return NSLocalizedString("Invisible mode makes you appear to be offline. To allow special friends to know you are online go to your Settings and add their name to the Visible User List.\nAre you sure you want to do this?", comment: "Alert")
    }
    static func profileNextDateDisplayNameAlert(_ nextChangeDate: String) -> String {
        return NSLocalizedString("Please note that you will not be able to change this until %@", comment: "Warning")
    }
    static func profileGiftSendIMButton() -> String {
        return NSLocalizedString("Send IM", comment: "Button")
    }
    static func profileYouHaveNoSubscription() -> String {
        return NSLocalizedString("You have no subscription", comment: "Label")
    }
    static func roomSortingMaleFemale() -> String {
        return NSLocalizedString("Females/Males", comment: "")
    }

    static func roomSortingAlphabetical() -> String {
        return NSLocalizedString("Alphabetical", comment: "")
    }

    static func roomSortingWhosViewingYou() -> String {
        return NSLocalizedString("Who's viewing you", comment: "")
    }

    static func roomSortingOnlyAvailableToSubscribers() -> String {
        return NSLocalizedString("Sorting features are only available to subscribers", comment: "")
    }

    static func roomSortingUpgradeToChange() -> String {
        return NSLocalizedString("Upgrade to change sorting to:", comment: "")
    }
    
    static func roomPositiveBarUserViewedYourCam(_ userDisplayName: String) -> String {
        return NSLocalizedString("%@ viewed your webcam", comment: "")
    }
    
    static func roomPositiveBarUserSentRoomGift(_ userDisplayName: String) -> String {
        return NSLocalizedString("%@ sent room a gift", comment: "")
    }
    
    static func roomPositiveBarUserSentUserGift(_ userDisplayName: String) -> String {
        return NSLocalizedString("%@ sent you a gift", comment: "")
    }
    
    static func roomPositiveBarYouSentUserGift(_ userDisplayName: String) -> String {
        return NSLocalizedString("You sent a gift to %@", comment: "")
    }

    static var coinsAreNotAvailableForPurchase: String {
        return NSLocalizedString("Sorry, coins aren’t available to be purchased right now. Please try again later", comment: "")
    }
}