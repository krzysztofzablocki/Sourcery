import AEXML
import Foundation

extension XCScheme {
    public final class TestableReference: Equatable {
        // MARK: - Attributes

        public var skipped: Bool
        public var parallelizable: Bool
        public var randomExecutionOrdering: Bool
        public var useTestSelectionWhitelist: Bool?
        public var buildableReference: BuildableReference
        public var skippedTests: [TestItem]
        public var selectedTests: [TestItem]

        // MARK: - Init

        public init(skipped: Bool,
                    parallelizable: Bool = false,
                    randomExecutionOrdering: Bool = false,
                    buildableReference: BuildableReference,
                    skippedTests: [TestItem] = [],
                    selectedTests: [TestItem] = [],
                    useTestSelectionWhitelist: Bool? = nil) {
            self.skipped = skipped
            self.parallelizable = parallelizable
            self.randomExecutionOrdering = randomExecutionOrdering
            self.buildableReference = buildableReference
            self.useTestSelectionWhitelist = useTestSelectionWhitelist
            self.selectedTests = selectedTests
            self.skippedTests = skippedTests
        }

        init(element: AEXMLElement) throws {
            skipped = element.attributes["skipped"] == "YES"
            parallelizable = element.attributes["parallelizable"] == "YES"
            useTestSelectionWhitelist = element.attributes["useTestSelectionWhitelist"] == "YES"
            randomExecutionOrdering = element.attributes["testExecutionOrdering"] == "random"
            buildableReference = try BuildableReference(element: element["BuildableReference"])

            if let selectedTests = element["SelectedTests"]["Test"].all {
                self.selectedTests = try selectedTests.map(TestItem.init)
            } else {
                selectedTests = []
            }
            if let skippedTests = element["SkippedTests"]["Test"].all {
                self.skippedTests = try skippedTests.map(TestItem.init)
            } else {
                skippedTests = []
            }
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = ["skipped": skipped.xmlString]
            attributes["parallelizable"] = parallelizable ? parallelizable.xmlString : nil
            if let useTestSelectionWhitelist = useTestSelectionWhitelist {
                attributes["useTestSelectionWhitelist"] = useTestSelectionWhitelist.xmlString
            }
            attributes["testExecutionOrdering"] = randomExecutionOrdering ? "random" : nil
            let element = AEXMLElement(name: "TestableReference",
                                       value: nil,
                                       attributes: attributes)
            element.addChild(buildableReference.xmlElement())

            if useTestSelectionWhitelist == true {
                if !selectedTests.isEmpty {
                    let selectedTestsElement = element.addChild(name: "SelectedTests")
                    selectedTests.forEach { selectedTest in
                        selectedTestsElement.addChild(selectedTest.xmlElement())
                    }
                }
            } else {
                if !skippedTests.isEmpty {
                    let skippedTestsElement = element.addChild(name: "SkippedTests")
                    skippedTests.forEach { skippedTest in
                        skippedTestsElement.addChild(skippedTest.xmlElement())
                    }
                }
            }
            return element
        }

        // MARK: - Equatable

        public static func == (lhs: TestableReference, rhs: TestableReference) -> Bool {
            lhs.skipped == rhs.skipped &&
                lhs.parallelizable == rhs.parallelizable &&
                lhs.randomExecutionOrdering == rhs.randomExecutionOrdering &&
                lhs.buildableReference == rhs.buildableReference &&
                lhs.useTestSelectionWhitelist == rhs.useTestSelectionWhitelist &&
                lhs.skippedTests == rhs.skippedTests &&
                lhs.selectedTests == rhs.selectedTests
        }
    }
}
