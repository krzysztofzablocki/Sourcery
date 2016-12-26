import UIKit
import RxSwift

enum RegistrationIndex {
    case mobileVC
    case emailVC
    case passwordVC
    case creditCardVC
    case zipCodeVC
    case confirmVC

    func toInt() -> Int {
        switch (self) {
            case .mobileVC: return 0
            case .emailVC: return 1
            case .passwordVC: return 1
            case .zipCodeVC: return 2
            case .creditCardVC: return 3
            case .confirmVC: return 4
        }
    }

    static func fromInt(_ index: Int) -> RegistrationIndex {
        switch (index) {
            case 0: return .mobileVC
            case 1: return .emailVC
            case 1: return .passwordVC
            case 2: return .zipCodeVC
            case 3: return .creditCardVC
            default : return .confirmVC
        }
    }
}

class RegistrationCoordinator: NSObject {

    let currentIndex = Variable(0)
    var storyboard: UIStoryboard!

    func viewControllerForIndex(_ index: RegistrationIndex) -> UIViewController {
        currentIndex.value = index.toInt()

        switch index {

        case .mobileVC:
            return storyboard.viewController(withID: .RegisterMobile)

        case .emailVC:
            return storyboard.viewController(withID: .RegisterEmail)

        case .passwordVC:
            return storyboard.viewController(withID: .RegisterPassword)

        case .zipCodeVC:
            return storyboard.viewController(withID: .RegisterPostalorZip)

        case .creditCardVC:
            if AppSetup.sharedState.disableCardReader {
                return storyboard.viewController(withID: .ManualCardDetailsInput)
            } else {
                return storyboard.viewController(withID: .RegisterCreditCard)
            }

        case .confirmVC:
            return storyboard.viewController(withID: .RegisterConfirm)
        }
    }

    func nextViewControllerForBidDetails(_ details: BidDetails) -> UIViewController {
        if notSet(details.newUser.phoneNumber.value) {
            return viewControllerForIndex(.mobileVC)
        }

        if notSet(details.newUser.email.value) {
            return viewControllerForIndex(.emailVC)
        }

        if notSet(details.newUser.password.value) {
            return viewControllerForIndex(.passwordVC)
        }

        if notSet(details.newUser.zipCode.value) && AppSetup.sharedState.needsZipCode {
            return viewControllerForIndex(.zipCodeVC)
        }

        if notSet(details.newUser.creditCardToken.value) {
            return viewControllerForIndex(.creditCardVC)
        }

        return viewControllerForIndex(.confirmVC)
    }
}

private func notSet(_ string: String?) -> Bool {
    return string?.isEmpty ?? true
}
