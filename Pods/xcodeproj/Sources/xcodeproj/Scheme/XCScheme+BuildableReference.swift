import AEXML
import Foundation

extension XCScheme {
    public final class BuildableReference: Equatable {
        // MARK: - Attributes

        public var referencedContainer: String

        private enum Blueprint: Equatable {
            case reference(PBXObjectReference)
            case string(String)

            var string: String {
                switch self {
                case let .reference(object): return object.value
                case let .string(string): return string
                }
            }
        }

        public func setBlueprint(_ object: PBXObject) {
            blueprint = .reference(object.reference)
        }

        private var blueprint: Blueprint
        public var blueprintIdentifier: String {
            return blueprint.string
        }

        public var buildableName: String
        public var buildableIdentifier: String
        public var blueprintName: String

        // MARK: - Init

        public init(referencedContainer: String,
                    blueprint: PBXObject,
                    buildableName: String,
                    blueprintName: String,
                    buildableIdentifier: String = "primary") {
            self.referencedContainer = referencedContainer
            self.blueprint = .reference(blueprint.reference)
            self.buildableName = buildableName
            self.buildableIdentifier = buildableIdentifier
            self.blueprintName = blueprintName
        }

        // MARK: - XML

        init(element: AEXMLElement) throws {
            guard let buildableIdentifier = element.attributes["BuildableIdentifier"] else {
                throw XCSchemeError.missing(property: "BuildableIdentifier")
            }
            guard let blueprintIdentifier = element.attributes["BlueprintIdentifier"] else {
                throw XCSchemeError.missing(property: "BlueprintIdentifier")
            }
            guard let buildableName = element.attributes["BuildableName"] else {
                throw XCSchemeError.missing(property: "BuildableName")
            }
            guard let blueprintName = element.attributes["BlueprintName"] else {
                throw XCSchemeError.missing(property: "BlueprintName")
            }
            guard let referencedContainer = element.attributes["ReferencedContainer"] else {
                throw XCSchemeError.missing(property: "ReferencedContainer")
            }
            self.buildableIdentifier = buildableIdentifier
            blueprint = .string(blueprintIdentifier)
            self.buildableName = buildableName
            self.blueprintName = blueprintName
            self.referencedContainer = referencedContainer
        }

        func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "BuildableReference",
                                value: nil,
                                attributes: [
                                    "BuildableIdentifier": buildableIdentifier,
                                    "BlueprintIdentifier": blueprint.string,
                                    "BuildableName": buildableName,
                                    "BlueprintName": blueprintName,
                                    "ReferencedContainer": referencedContainer,
                                ])
        }

        // MARK: - Equatable

        public static func == (lhs: BuildableReference, rhs: BuildableReference) -> Bool {
            return lhs.referencedContainer == rhs.referencedContainer &&
                lhs.blueprintIdentifier == rhs.blueprintIdentifier &&
                lhs.buildableName == rhs.buildableName &&
                lhs.blueprint == rhs.blueprint &&
                lhs.blueprintName == rhs.blueprintName
        }
    }
}
