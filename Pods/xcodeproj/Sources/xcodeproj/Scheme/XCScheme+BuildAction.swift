import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class BuildAction: SerialAction {
        public final class Entry: Equatable {
            public enum BuildFor {
                case running, testing, profiling, archiving, analyzing
                public static var `default`: [BuildFor] = [.running, .testing, .archiving, .analyzing]
                public static var indexing: [BuildFor] = [.testing, .analyzing, .archiving]
                public static var testOnly: [BuildFor] = [.testing, .analyzing]
            }

            // MARK: - Attributes

            public var buildableReference: BuildableReference
            public var buildFor: [BuildFor]

            // MARK: - Init

            public init(buildableReference: BuildableReference,
                        buildFor: [BuildFor]) {
                self.buildableReference = buildableReference
                self.buildFor = buildFor
            }

            init(element: AEXMLElement) throws {
                var buildFor: [BuildFor] = []
                if (element.attributes["buildForTesting"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.testing)
                }
                if (element.attributes["buildForRunning"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.running)
                }
                if (element.attributes["buildForProfiling"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.profiling)
                }
                if (element.attributes["buildForArchiving"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.archiving)
                }
                if (element.attributes["buildForAnalyzing"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.analyzing)
                }
                self.buildFor = buildFor
                buildableReference = try BuildableReference(element: element["BuildableReference"])
            }

            // MARK: - XML

            fileprivate func xmlElement() -> AEXMLElement {
                var attributes: [String: String] = [:]
                attributes["buildForTesting"] = buildFor.contains(.testing) ? "YES" : "NO"
                attributes["buildForRunning"] = buildFor.contains(.running) ? "YES" : "NO"
                attributes["buildForProfiling"] = buildFor.contains(.profiling) ? "YES" : "NO"
                attributes["buildForArchiving"] = buildFor.contains(.archiving) ? "YES" : "NO"
                attributes["buildForAnalyzing"] = buildFor.contains(.analyzing) ? "YES" : "NO"
                let element = AEXMLElement(name: "BuildActionEntry",
                                           value: nil,
                                           attributes: attributes)
                element.addChild(buildableReference.xmlElement())
                return element
            }

            // MARK: - Equatable

            public static func == (lhs: Entry, rhs: Entry) -> Bool {
                return lhs.buildableReference == rhs.buildableReference &&
                    lhs.buildFor == rhs.buildFor
            }
        }

        // MARK: - Attributes

        public var buildActionEntries: [Entry]
        public var parallelizeBuild: Bool
        public var buildImplicitDependencies: Bool

        // MARK: - Init

        public init(buildActionEntries: [Entry] = [],
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    parallelizeBuild: Bool = false,
                    buildImplicitDependencies: Bool = false) {
            self.buildActionEntries = buildActionEntries
            self.parallelizeBuild = parallelizeBuild
            self.buildImplicitDependencies = buildImplicitDependencies
            super.init(preActions, postActions)
        }

        override init(element: AEXMLElement) throws {
            parallelizeBuild = element.attributes["parallelizeBuildables"].map { $0 == "YES" } ?? true
            buildImplicitDependencies = element.attributes["buildImplicitDependencies"].map { $0 == "YES" } ?? true
            buildActionEntries = try element["BuildActionEntries"]["BuildActionEntry"]
                .all?
                .map(Entry.init) ?? []
            try super.init(element: element)
        }

        // MARK: - Helpers

        public func add(buildActionEntry: Entry) -> BuildAction {
            var buildActionEntries = self.buildActionEntries
            buildActionEntries.append(buildActionEntry)
            return BuildAction(buildActionEntries: buildActionEntries,
                               parallelizeBuild: parallelizeBuild)
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BuildAction",
                                       value: nil,
                                       attributes: [
                                           "parallelizeBuildables": parallelizeBuild.xmlString,
                                           "buildImplicitDependencies": buildImplicitDependencies.xmlString,
                                       ])
            super.writeXML(parent: element)
            let entries = element.addChild(name: "BuildActionEntries")
            buildActionEntries.forEach { entry in
                entries.addChild(entry.xmlElement())
            }
            return element
        }

        // MARK: - Equatable

        override func isEqual(to: Any?) -> Bool {
            guard let rhs = to as? BuildAction else { return false }
            return super.isEqual(to: to) &&
                buildActionEntries == rhs.buildActionEntries &&
                parallelizeBuild == rhs.parallelizeBuild &&
                buildImplicitDependencies == rhs.buildImplicitDependencies
        }
    }
}
