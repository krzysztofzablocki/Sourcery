import Foundation
import SwiftyJSON

final class Image: NSObject, JSONAbleType {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize
    let aspectRatio: CGFloat?

    let baseURL: String
    let tileSize: Int
    let maxTiledHeight: Int
    let maxTiledWidth: Int
    let maxLevel: Int
    let isDefault: Bool

    init(id: String, imageFormatString: String, imageVersions: [String], imageSize: CGSize, aspectRatio: CGFloat?, baseURL: String, tileSize: Int, maxTiledHeight: Int, maxTiledWidth: Int, maxLevel: Int, isDefault: Bool) {
        self.id = id
        self.imageFormatString = imageFormatString
        self.imageVersions = imageVersions
        self.imageSize = imageSize
        self.aspectRatio = aspectRatio
        self.baseURL = baseURL
        self.tileSize = tileSize
        self.maxTiledHeight = maxTiledHeight
        self.maxTiledWidth = maxTiledWidth
        self.maxLevel = maxLevel
        self.isDefault = isDefault
    }

    static func fromJSON(_ json: [String: Any]) -> Image {
        let json = JSON(json)

        let id = json["id"].stringValue
        let imageFormatString = json["image_url"].stringValue
        let imageVersions = (json["image_versions"].object as? [String]) ?? []
        let imageSize = CGSize(width: json["original_width"].int ?? 1, height: json["original_height"].int ?? 1)
        let aspectRatio = { () -> CGFloat? in
            if let aspectRatio = json["aspect_ratio"].float {
                return CGFloat(aspectRatio)
            }
            return nil
        }()

        let baseURL = json["tile_base_url"].stringValue
        let tileSize = json["tile_size"].intValue
        let maxTiledHeight = json["max_tiled_height"].int ?? 1
        let maxTiledWidth = json["max_tiled_width"].int ?? 1
        let isDefault = json["is_default"].bool ?? false

        let dimension = max( maxTiledWidth, maxTiledHeight)
        let logD = logf( Float(dimension) )
        let log2 = Float(logf(2))

        let maxLevel = Int( ceilf( logD / log2) )

        return Image(id: id, imageFormatString: imageFormatString, imageVersions: imageVersions, imageSize: imageSize, aspectRatio: aspectRatio, baseURL: baseURL, tileSize: tileSize, maxTiledHeight: maxTiledHeight, maxTiledWidth: maxTiledWidth, maxLevel: maxLevel, isDefault: isDefault)
    }

    func thumbnailURL() -> URL? {
        let preferredVersions = { () -> Array<String> in
            // For very tall images, the "medium" version looks terribad.
            // In the long-term, we have an issue to fix this for good: https://github.com/artsy/eidolon/issues/396
            if ["57be35d7a09a6711ab004fa5", "57be1fb4cd530e65fe000862"].contains(self.id) {
                return ["large", "larger"]
            } else {
                return ["medium", "large", "larger"]
            }
        }()

        return urlFromPreferenceList(preferredVersions)
    }

    func fullsizeURL() -> URL? {
        return urlFromPreferenceList(["larger", "large", "medium"])
    }

    fileprivate func urlFromPreferenceList(_ preferenceList: Array<String>) -> URL? {
        if let format = preferenceList.filter({ self.imageVersions.contains($0) }).first {
            let path = NSString(string: self.imageFormatString).replacingOccurrences(of: ":version", with: format)
            return URL(string: path)
        }
        return nil
    }
}
