import RxSwift

class NewUser {
    var email = Variable<String?>(nil)
    var password = Variable<String?>(nil)
    var phoneNumber = Variable<String?>(nil)
    var creditCardDigit = Variable<String?>(nil)
    var creditCardToken = Variable<String?>(nil)
    var creditCardName = Variable<String?>(nil)
    var creditCardType = Variable<String?>(nil)
    var zipCode = Variable<String?>(nil)
    var name = Variable<String?>(nil)

    var hasBeenRegistered = Variable(false)

    var swipedCreditCard = false
}
