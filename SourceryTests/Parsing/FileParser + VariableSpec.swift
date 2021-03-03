import Quick
import Nimble
import PathKit
@testable import Sourcery
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserVariableSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("Parser") {
            describe("parseVariable") {
                func parse(_ code: String) -> Variable? {
                    let wrappedCode =
                        """
                        struct Wrapper {
                            \(code)
                        }
                        """
                    guard let parser = try? makeParser(for: wrappedCode) else { fail(); return nil }
                    let result = try? parser.parse()
                    let variable = result?.types.first?.variables.first
                    variable?.definedInType = nil
                    variable?.definedInTypeName = nil
                    return variable
                }

                it("infers types for variables when it's easy") {
                    expect(parse("static let redirectButtonDefaultURL = URL(string: \"https://www.nytimes.com\")!")?.typeName).to(equal(TypeName("URL!")))

                    expect(parse(
                    """
                    var pointPool = {
                        ReusableItemPool<Point>(something: "cool")
                    }()
                    """
                    )?.typeName).to(equal(TypeName("ReusableItemPool<Point>")))
                }

                it("reports variable mutability") {
                    expect(parse("var name: String")?.isMutable).to(beTrue())
                    expect(parse("let name: String")?.isMutable).to(beFalse())
                    expect(parse("private(set) var name: String")?.isMutable).to(beTrue())
                    expect(parse("var name: String { return \"\" }")?.isMutable).to(beFalse())
                }

                it("extracts standard property correctly") {
                    expect(parse("var name: String")).to(equal(Variable(name: "name", typeName: TypeName("String"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("extracts property with custom access correctly") {
                    expect(parse("private var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName("String"),
                                         accessLevel: (read: .private, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "private")
                                         ]
                                )
                        ))

                    expect(parse("private(set) var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName("String"),
                                         accessLevel: (read: .internal, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "private", detail: "set")
                                         ]
                                )
                        ))

                    expect(parse("public private(set) var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName("String"),
                                         accessLevel: (read: .public, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "public"),
                                            Modifier(name: "private", detail: "set")
                                         ]
                                )
                        ))
                }

                context("given variable with initial value") {
                    it("extracts default value") {
                        expect(parse("var name: String = String()")?.defaultValue).to(equal("String()"))
                        expect(parse("var name = Parent.Children.init()")?.defaultValue).to(equal("Parent.Children.init()"))
                        expect(parse("var name = [[1, 2], [1, 2]]")?.defaultValue).to(equal("[[1, 2], [1, 2]]"))
                        expect(parse("var name = { return 0 }()")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(parse("var name = \t\n { return 0 }() \t\n")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(parse("var name: Int = \t\n { return 0 }() \t\n")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(parse("var name: String = String() { didSet { print(0) } }")?.defaultValue).to(equal("String()"))
                        expect(parse("var name: String = String() {\n\tdidSet { print(0) }\n}")?.defaultValue).to(equal("String()"))
                        expect(parse("var name: String = String()\n{\n\twillSet { print(0) }\n}")?.defaultValue).to(equal("String()"))
                    }

                    it("extracts property with default initializer correctly") {
                        expect(parse("var name = String()")?.typeName).to(equal(TypeName("String")))
                        expect(parse("var name = Parent.Children.init()")?.typeName).to(equal(TypeName("Parent.Children")))
                        expect(parse("var name: String? = String()")?.typeName).to(equal(TypeName("String?")))
                        expect(parse("var name = { return 0 }() ")?.typeName).toNot(equal(TypeName("{ return 0 }")))

                        expect(parse(
                        """
                        var reducer = Reducer<WorkoutTemplate.State, WorkoutTemplate.Action, GlobalEnvironment<Programs.Environment>>.combine(
                            periodizationConfiguratorReducer.optional().pullback(state: \\.periodizationConfigurator, action: /WorkoutTemplate.Action.periodizationConfigurator, environment: { $0.map { _ in Programs.Environment() } })) {
                            somethingUnrealted.init()
                        }
                        """
                        )?.typeName).to(equal(TypeName("Reducer<WorkoutTemplate.State, WorkoutTemplate.Action, GlobalEnvironment<Programs.Environment>>")))
                    }

                    it("extracts property with literal value correctrly") {
                        expect(parse("var name = 1")?.typeName).to(equal(TypeName("Int")))
                        expect(parse("var name = 1.0")?.typeName).to(equal(TypeName("Double")))
                        expect(parse("var name = \"1\"")?.typeName).to(equal(TypeName("String")))
                        expect(parse("var name = true")?.typeName).to(equal(TypeName("Bool")))
                        expect(parse("var name = false")?.typeName).to(equal(TypeName("Bool")))
                        expect(parse("var name = nil")?.typeName).to(equal(TypeName("Optional")))
                        expect(parse("var name = Optional.none")?.typeName).to(equal(TypeName("Optional")))
                        expect(parse("var name = Optional.some(1)")?.typeName).to(equal(TypeName("Optional")))
                        expect(parse("var name = Foo.Bar()")?.typeName).to(equal(TypeName("Foo.Bar")))
                    }

                    it("extracts property with array literal value correctly") {
                        expect(parse("var name = [Int]()")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(parse("var name = [1]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(parse("var name = [1, 2]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(parse("var name = [1, \"a\"]")?.typeName).to(equal(TypeName.buildArray(of: .Any)))
                        expect(parse("var name = [1, nil]")?.typeName).to(equal(TypeName.buildArray(of: TypeName.Int.asOptional)))
                        expect(parse("var name = [1, [1, 2]]")?.typeName).to(equal(TypeName.buildArray(of: .Any)))
                        expect(parse("var name = [[1, 2], [1, 2]]")?.typeName).to(equal(TypeName.buildArray(of: TypeName.buildArray(of: .Int))))
                        expect(parse("var name = [Int()]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                    }

                    it("extracts property with dictionary literal value correctly") {
                        expect(parse("var name = [Int: Int]()")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(parse("var name = [1: 2]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(parse("var name = [1: 2, 2: 3]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(parse("var name = [1: 1, 2: \"a\"]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Any)))
                        expect(parse("var name = [1: 1, 2: nil]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: TypeName.Int.asOptional)))
                        expect(parse("var name = [1: 1, 2: [1, 2]]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Any)))
                        expect(parse("var name = [[1: 1, 2: 2], [1: 1, 2: 2]]")?.typeName).to(equal(TypeName.buildArray(of: .buildDictionary(key: .Int, value: .Int))))
                        expect(parse("var name = [1: [1: 1, 2: 2], 2: [1: 1, 2: 2]]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .buildDictionary(key: .Int, value: .Int))))
                        expect(parse("var name = [Int(): String()]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .String)))
                    }

                    it("matches inference with parser tuple") {
                        let infer = parse("var name = (1, b: \"[2,3]\", c: 1)")?.typeName
                        let parsed = parse("var name: (Int, b: String, c: Int)")?.typeName
                        expect(infer).to(equal(parsed))
                    }

                    it("extracts property with tuple literal value correctly") {
                        expect(parse("var name = (1, 2)")?.typeName).to(equal(TypeName.buildTuple(TypeName.Int, TypeName.Int)))
                        expect(parse("var name = (1, b: \"[2,3]\", c: 1)")?.typeName).to(equal(TypeName.buildTuple(.init(name: "0", typeName: .Int), .init(name: "b", typeName: .String), .init(name: "c", typeName: .Int))))
                        expect(parse("var name = (_: 1, b: 2)")?.typeName).to(equal(TypeName.buildTuple(.init(name: "0", typeName: .Int), .init(name: "b", typeName: .Int))))
                        expect(parse("var name = ((1, 2), [\"a\": \"b\"])")?.typeName).to(equal(TypeName.buildTuple(TypeName.buildTuple(TypeName.Int, TypeName.Int), TypeName.buildDictionary(key: .String, value: .String))))
                        expect(parse("var name = ((1, 2), [1, 2])")?.typeName).to(equal(TypeName.buildTuple(TypeName.buildTuple(TypeName.Int, TypeName.Int), TypeName.buildArray(of: .Int))))
                        let variable = parse("var name = ((1, 2), [\"a,b\": \"b\"])")
                        expect(variable?.typeName)
                          .to(
                            equal(TypeName.buildTuple(
                              .buildTuple(.Int, .Int),
                              .buildDictionary(key: .String, value: .String))
                            ))
                    }
                }

                it("extracts standard let property correctly") {
                    let r = parse("let name: String")
                    expect(r).to(equal(Variable(name: "name", typeName: TypeName("String"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                }

                it("extracts computed property correctly") {
                    expect(parse("var name: Int { return 2 }")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)))
                    expect(parse("let name: Int")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                    expect(parse("var name: Int")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(parse("var name: Int { \nget { return 0 } \nset {} }")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: true)))
                    expect(parse("var name: Int \n{ willSet { } }")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(parse("var name: Int { \ndidSet {} }")).to(equal(Variable(name: "name", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("extracts generic property correctly") {
                    expect(parse("let name: Observable<Int>")).to(equal(Variable(name: "name", typeName:
                    TypeName("Observable<Int>", generic: .init(name: "Observable", typeParameters: [.init(typeName: TypeName("Int"))])
                    ), accessLevel: (read: .internal, write: .none), isComputed: false)))
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
