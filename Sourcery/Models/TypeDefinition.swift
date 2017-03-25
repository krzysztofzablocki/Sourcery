import Foundation

class TypeDefinition: NSObject, SourceryModel {

    /// The path to the file of the definition
    var path: String

    /// The position of the starting `{` of the body of the type definition in the file where the type is defined
    var bodyOffset: Int

    /// The position right after the starting `{` of the type definition
    var bodyStartPosition: Int {
        return bodyOffset + 1
    }

    /// The length of the body of the definition
    var bodyLength: Int

    /// The position right before the closing `}` of the type definition
    var bodyEndPosition: Int {
        return bodyOffset + bodyLength
    }

    init(path: String, bodyOffset: Int, bodyLength: Int) {
        self.path = path
        self.bodyOffset = bodyOffset
        self.bodyLength = bodyLength
    }

    // sourcery:inline:TypeDefinition.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let path: String = aDecoder.decode(forKey: "path") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["path"])); fatalError() }; self.path = path
            self.bodyOffset = aDecoder.decode(forKey: "bodyOffset")
            self.bodyLength = aDecoder.decode(forKey: "bodyLength")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.bodyOffset, forKey: "bodyOffset")
            aCoder.encode(self.bodyLength, forKey: "bodyLength")
        }
    // sourcery:end
}
