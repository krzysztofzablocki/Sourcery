import Foundation

/// contains a PBXObject as well as it's reference
public class ObjectReference<T: PBXObject>: Equatable {

    public let reference: String
    public let object: T
    
    public init(reference: String, object: T) {
        self.reference = reference
        self.object = object
    }

    public static func == (lhs: ObjectReference,
                           rhs: ObjectReference) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.object == rhs.object
    }
}

extension Dictionary where Key == String, Value: PBXObject {

    public var objectReferences: [ObjectReference<Value>] {
        return self.map(ObjectReference.init)
    }
}
