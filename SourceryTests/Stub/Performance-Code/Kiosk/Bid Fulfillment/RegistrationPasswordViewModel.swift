import Foundation
import RxSwift
import Moya
import Action

protocol RegistrationPasswordViewModelType {
    var emailExists: Observable<Bool> { get }
    var action: CocoaAction! { get }

    func userForgotPassword() -> Observable<Void>
}

class RegistrationPasswordViewModel: RegistrationPasswordViewModelType {

    fileprivate let password = Variable("")

    var action: CocoaAction!
    let provider: Networking

    let email: String
    let emailExists: Observable<Bool>

    let disposeBag = DisposeBag()

    init(provider: Networking, password: Observable<String>, execute: Observable<Void>, completed: PublishSubject<Void>, email: String) {
        self.provider = provider
        self.email = email

        let checkEmail = provider
            .request(ArtsyAPI.findExistingEmailRegistration(email: email))
            .map(responseIsOK)
            .shareReplay(1)

        emailExists = checkEmail

        password.bindTo(self.password).addDisposableTo(disposeBag)

        let password = self.password

        // Action takes nothing, is enabled if the password is valid, and does the following:
        // Check if the email exists, it tries to log in.
        // If it doesn't exist, then it does nothing.
        let action = CocoaAction(enabledIf: password.asObservable().map(isStringLengthAtLeast(length: 6))) { _ in

            return self.emailExists
                .flatMap { exists -> Observable<Void> in
                    if exists {
                        let endpoint: ArtsyAPI = ArtsyAPI.xAuth(email: email, password: password.value )
                        return provider
                            .request(endpoint)
                            .filterSuccessfulStatusCodes()
                            .map(void)
                    } else {
                        // Return a non-empty observable, so that the action sends something on its elements observable.
                        return .just(Void())
                    }
                }
                .doOnCompleted {
                    completed.onCompleted()
                }
        }

        self.action = action

        execute
            .subscribe { _ in
                action.execute(Void())
            }
            .addDisposableTo(disposeBag)
    }

    func userForgotPassword() -> Observable<Void> {
        let endpoint = ArtsyAPI.lostPasswordNotification(email: email)
        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnNext { _ in
                logger.log("Sent forgot password request")
            }
    }
}
