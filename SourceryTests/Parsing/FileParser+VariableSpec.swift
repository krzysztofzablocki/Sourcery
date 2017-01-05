import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return Structure(file: File(contents: source)).dictionary
}

class FileParserVariableSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Parser") {
            describe("parseVariable") {
                func parse(_ code: String) -> Variable? {
                    let parser = FileParser(contents: code)
                    let code = build(code)
                    guard let substructures = code?[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable],
                          let src = substructures.first as? [String: SourceKitRepresentable] else {
                        fail()
                        return nil
                    }
                    return parser.parseVariable(src)
                }

                it("ignores private variables") {
                    expect(parse("private var name: String")).to(beNil())
                    expect(parse("fileprivate var name: String")).to(beNil())
                }

                it("extracts standard property correctly") {
                    expect(parse("var name: String")).to(equal(Variable(name: "name", typeName: TypeName("String"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("extracts property with default initializer correctly") {
                    expect(parse("var name = String()")).to(equal(Variable(name: "name", typeName: TypeName("String"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(parse("var name = Parent.Children.init()")).to(equal(Variable(name: "name", typeName: TypeName("Parent.Children"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(parse("var name: String? = String()")).to(equal(Variable(name: "name", typeName: TypeName("String?"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("extracts standard let property correctly") {
                    let r = parse("let name: String")
                    expect(r).to(equal(Variable(name: "name", typeName: TypeName("String"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                }

                it("extracts computed property correctly") {
                    expect(parse("var name: Int { return 2 }")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)))
                }

                it("extracts generic property correctly") {
                    expect(parse("let name: Observable<Int>")).to(equal(Variable(name: "name", typeName: TypeName("Observable<Int>"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                }

                it("extracts property with didSet correctly") {
                    expect(parse(
                            "var name: Int? {\n" +
                                    "didSet { _ = 2 }\n" +
                                    "willSet { _ = 4 }\n" +
                                    "}")).to(equal(Variable(name: "name", typeName: TypeName("Int?"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                context("given it has sourcery annotations") {

                    it("extracts single annotation") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)

                        expect(parse("// sourcery: skipEquability\n" +
                                             "var name: Int { return 2 }")).to(equal(expectedVariable))
                    }

                    it("extracts multiple annotations on the same line") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)
                        expectedVariable.annotations["jsonKey"] = "json_key" as NSString

                        expect(parse("// sourcery: skipEquability, jsonKey = \"json_key\"\n" +
                                             "var name: Int { return 2 }")).to(equal(expectedVariable))
                    }

                    it("extracts multi-line annotations, including numbers") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)
                        expectedVariable.annotations["jsonKey"] = "json_key" as NSString
                        expectedVariable.annotations["thirdProperty"] = NSNumber(value: -3)

                        let result = parse(        "// sourcery: skipEquability, jsonKey = \"json_key\"\n" +
                                                           "// sourcery: thirdProperty = -3\n" +
                                                           "var name: Int { return 2 }")
                        expect(result).to(equal(expectedVariable))
                    }

                    it("extracts annotations interleaved with comments") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["isSet"] = NSNumber(value: true)
                        expectedVariable.annotations["numberOfIterations"] = NSNumber(value: 2)

                        let result = parse(        "// sourcery: isSet\n" +
                                                           "/// isSet is used for something useful\n" +
                                                           "// sourcery: numberOfIterations = 2\n" +
                                                           "var name: Int { return 2 }")
                        expect(result).to(equal(expectedVariable))
                    }

                    it("stops extracting annotations if it encounters a non-comment line") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["numberOfIterations"] = NSNumber(value: 2)

                        let result = parse(        "// sourcery: isSet\n" +
                                                           "\n" +
                                                           "// sourcery: numberOfIterations = 2\n" +
                                                           "var name: Int { return 2 }")
                        expect(result).to(equal(expectedVariable))
                    }
                }
            }
        }
    }
}
