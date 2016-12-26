import Foundation
import SwiftyJSON

final class Artist: NSObject, JSONAbleType {

    let id: String
    dynamic var name: String
    let sortableID: String?

    var blurb: String?

    init(id: String, name: String, sortableID: String?) {
        self.id = id
        self.name = name
        self.sortableID = sortableID
    }

    static func fromJSON(_ json: [String: Any]) -> Artist {
        let json = JSON(json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let sortableID = json["sortable_id"].string
        return Artist(id: id, name:name, sortableID:sortableID)
    }

}
