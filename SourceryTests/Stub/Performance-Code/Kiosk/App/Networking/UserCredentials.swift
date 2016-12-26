import Foundation

struct UserCredentials {
    let user: User
    let accessToken: String

    init(user: User, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}
