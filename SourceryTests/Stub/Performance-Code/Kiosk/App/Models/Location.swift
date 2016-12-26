import UIKit
import SwiftyJSON

final class Location: NSObject, JSONAbleType {
    let address: String
    let address2: String
    let city: String
    let state: String
    let stateCode: String
    var postalCode: String

    init(address: String, address2: String, city: String, state: String, stateCode: String, postalCode: String) {
        self.address = address
        self.address2 = address2
        self.city = city
        self.state = state
        self.stateCode = stateCode
        self.postalCode = postalCode
    }

    static func fromJSON(_ json: [String: Any]) -> Location {
        let json = JSON(json)

        let address =  json["address"].stringValue
        let address2 =  json["address_2"].stringValue
        let city =  json["city"].stringValue
        let state =  json["state"].stringValue
        let stateCode =  json["state_code"].stringValue
        let postalCode =  json["postal_code"].stringValue

        return Location(address: address, address2: address2, city: city, state: state, stateCode: stateCode, postalCode: postalCode)
    }

}
