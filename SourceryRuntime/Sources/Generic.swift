import Foundation

@objcMembers public final class Generic: NSObject, SourceryModel {
    public let name: String
    public var constraints: [GenericTypeParameterConstraint]

    public init(name: String, constraints: [GenericTypeParameterConstraint] = []) {
        self.name = name
        self.constraints = constraints
    }

    // sourcery:inline:Generic.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let constraints: [GenericTypeParameterConstraint] = aDecoder.decode(forKey: "constraints") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["constraints"])); fatalError() }; self.constraints = constraints
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.constraints, forKey: "constraints")
        }
    // sourcery:end
}
