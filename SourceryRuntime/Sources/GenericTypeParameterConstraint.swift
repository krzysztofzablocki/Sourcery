import Foundation

@objcMembers public final class GenericTypeParameterConstraint: NSObject, SourceryModel {
    public let name: TypeName
    public let type: Type?

    public init(name: TypeName, type: Type? = nil) {
        self.name = name
        self.type = type
    }

    // sourcery:inline:GenericTypeParameterConstraint.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: TypeName = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.type = aDecoder.decode(forKey: "type")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.type, forKey: "type")
        }
    // sourcery:end
}
