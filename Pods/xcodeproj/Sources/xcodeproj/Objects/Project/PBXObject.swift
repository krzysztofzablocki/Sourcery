// sourcery:file: skipEquality
import Foundation

/// Class that represents a project element.
public class PBXObject: Hashable, Decodable, Equatable, AutoEquatable {
    /// Returns the unique identifier.
    /// Note: The unique identifier of an object might change when the project gets written.
    /// If you use this identifier from a scheme, make sure the project is written before the project is.
    public var uuid: String {
        return reference.value
    }

    /// The object reference in the project that contains it.
    let reference: PBXObjectReference

    /**
     Used to differentiate this object from other equatable ones for the purposes of uuid generation.

     This shouldn't be required to be set in normal circumstances.
     In some rare cases xcodeproj doesn't have enough context about otherwise equatable objects,
     so it has to resolve automatic uuid conflicts by appending numbers.
     This property can be used to provide more context to disambiguate these objects,
     which will result in more deterministic uuids.
     */
    public var context: String?

    // MARK: - Init

    init() {
        reference = PBXObjectReference()
        reference.setObject(self)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case reference
    }

    /// Initializes the object from its project representation.
    ///
    /// - Parameter decoder: XcodeprojPropertyListDecoder decoder.
    /// - Throws: an error if the object cannot be parsed.
    public required init(from decoder: Decoder) throws {
        let referenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reference: String = try container.decode(.reference)
        self.reference = referenceRepository.getOrCreate(reference: reference, objects: objects)
        self.reference.setObject(self)
    }

    /// Object isa (type id)
    public static var isa: String {
        return String(describing: self)
    }

    public static func == (lhs: PBXObject,
                           rhs: PBXObject) -> Bool {
        return lhs.isEqual(to: rhs)
    }

    @objc dynamic func isEqual(to _: Any?) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(reference)
    }

    /// Returns the objects the object belong to.
    ///
    /// - Returns: objects the object belongs to.
    /// - Throws: an error if this method is accessed before the object has been added to a project.
    func objects() throws -> PBXObjects {
        guard let objects = self.reference.objects else {
            let objectType = String(describing: type(of: self))
            throw PBXObjectError.orphaned(type: objectType, reference: reference.value)
        }
        return objects
    }
}
