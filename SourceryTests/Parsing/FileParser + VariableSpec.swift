import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserVariableSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("Parser") {
            describe("parseVariable") {
                func parse(_ code: String, parseDocumentation: Bool = false) -> FileParserResult? {
                    guard let parser = try? makeParser(for: code, parseDocumentation: parseDocumentation) else { fail(); return nil }
                    return try? parser.parse()
                }

                func variable(_ code: String, parseDocumentation: Bool = false) -> Variable? {
                    let wrappedCode =
                        """
                        struct Wrapper {
                            \(code)
                        }
                        """
                    let result = parse(wrappedCode, parseDocumentation: parseDocumentation)
                    let variable = result?.types.first?.variables.first
                    variable?.definedInType = nil
                    variable?.definedInTypeName = nil
                    return variable
                }

                it("infers generic type initializer correctly") {
                    func verify(_ type: String) {
                        let parsedTypeName = variable("static let generic: \(type)")?.typeName
                        expect(variable("static let generic = \(type)(value: true)")?.typeName).to(equal(parsedTypeName))
                    }

                    verify("GenericType<Bool>")
                    verify("GenericType<Optional<Int>>")
                    verify("GenericType<Whatever, Int, [Float]>")

                    expect(variable(
                    """
                    var pointPool = {
                        ReusableItemPool<Point>(something: "cool")
                    }()
                    """
                    )?.typeName).to(equal(variable("static let generic: ReusableItemPool<Point>")?.typeName))
                }

                it("infers types for variables when it's easy") {
                    expect(variable("static let redirectButtonDefaultURL = URL(string: \"https://www.nytimes.com\")!")?.typeName).to(equal(TypeName(name: "URL!")))
                }

                it("reports variable mutability") {
                    expect(variable("var name: String")?.isMutable).to(beTrue())
                    expect(variable("let name: String")?.isMutable).to(beFalse())
                    expect(variable("private(set) var name: String")?.isMutable).to(beTrue())
                    expect(variable("var name: String { return \"\" }")?.isMutable).to(beFalse())
                }

                it("extracts standard property correctly") {
                    expect(variable("var name: String")).to(equal(Variable(name: "name", typeName: TypeName(name: "String"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("infers types for variable when type is an inner type of the contained type correctly") {
                    let content = """
                    struct X {
                      struct A {}

                      let a: A
                    }

                    struct A {}
                    """
                    let expectedVariable = Variable(name: "a", typeName: TypeName("X.A"), type: Type(name: "A"), accessLevel: (.internal, .none), isComputed: false, isAsync: false, throws: false, isStatic: false, defaultValue: nil, attributes: [:], modifiers: [], annotations: [:], documentation: [], definedInTypeName: TypeName("X"))
                    let result = parse(content)
                    let variable = result?.types.first?.variables.first
                    expect(variable).to(equal(expectedVariable))
                }

                it("extracts with custom access correctly") {
                    expect(variable("private var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName(name: "String"),
                                         accessLevel: (read: .private, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "private")
                                         ]
                                )
                        ))

                    expect(variable("private(set) var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName(name: "String"),
                                         accessLevel: (read: .internal, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "private", detail: "set")
                                         ]
                                )
                        ))

                    expect(variable("public private(set) var name: String"))
                        .to(equal(
                                Variable(name: "name",
                                         typeName: TypeName(name: "String"),
                                         accessLevel: (read: .public, write: .private),
                                         isComputed: false,
                                         modifiers: [
                                            Modifier(name: "public"),
                                            Modifier(name: "private", detail: "set")
                                         ]
                                )
                        ))
                }
                
                context("given variable defined in protocol") {
                    func variable(_ code: String) -> Variable? {
                        let wrappedCode =
                            """
                            protocol Wrapper {
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
                    
                    it("reports variable mutability") {
                        expect(variable("var name: String { get } ")?.isMutable).to(beFalse())
                        expect(variable("var name: String { get set }")?.isMutable).to(beTrue())
                        
                        let internalVariable = variable("var name: String { get set }")
                        expect(internalVariable?.writeAccess).to(equal("internal"))
                        expect(internalVariable?.readAccess).to(equal("internal"))

                        let publicVariable = variable("public var name: String { get set }")
                        expect(publicVariable?.writeAccess).to(equal("public"))
                        expect(publicVariable?.readAccess).to(equal("public"))
                    }
                    
                    it("reports variable concurrency") {
                        expect(variable("var name: String { get } ")?.isAsync).to(beFalse())
                        expect(variable("var name: String { get async }")?.isAsync).to(beTrue())
                    }
                    
                    it("reports variable throwability") {
                        expect(variable("var name: String { get } ")?.throws).to(beFalse())
                        expect(variable("var name: String { get throws }")?.throws).to(beTrue())
                    }
                }

                context("given variable with initial value") {
                    it("extracts default value") {
                        expect(variable("var name: String = String()")?.defaultValue).to(equal("String()"))
                        expect(variable("var name = Parent.Children.init()")?.defaultValue).to(equal("Parent.Children.init()"))
                        expect(variable("var name = [[1, 2], [1, 2]]")?.defaultValue).to(equal("[[1, 2], [1, 2]]"))
                        expect(variable("var name = { return 0 }()")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(variable("var name = \t\n { return 0 }() \t\n")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(variable("var name: Int = \t\n { return 0 }() \t\n")?.defaultValue).to(equal("{ return 0 }()"))
                        expect(variable("var name: String = String() { didSet { print(0) } }")?.defaultValue).to(equal("String()"))
                        expect(variable("var name: String = String() {\n\tdidSet { print(0) }\n}")?.defaultValue).to(equal("String()"))
                        expect(variable("var name: String = String()\n{\n\twillSet { print(0) }\n}")?.defaultValue).to(equal("String()"))
                    }

                    it("extracts property with default initializer correctly") {
                        expect(variable("var name = String()")?.typeName).to(equal(TypeName(name: "String")))
                        expect(variable("var name = Parent.Children.init()")?.typeName).to(equal(TypeName(name: "Parent.Children")))
                        expect(variable("var name: String? = String()")?.typeName).to(equal(TypeName(name: "String?")))
                        expect(variable("var name = { return 0 }() ")?.typeName).toNot(equal(TypeName(name: "{ return 0 }")))

                        expect(variable(
                        """
                        var reducer = Reducer<WorkoutTemplate.State, WorkoutTemplate.Action, GlobalEnvironment<Programs.Environment>>.combine(
                            periodizationConfiguratorReducer.optional().pullback(state: \\.periodizationConfigurator, action: /WorkoutTemplate.Action.periodizationConfigurator, environment: { $0.map { _ in Programs.Environment() } })) {
                            somethingUnrealted.init()
                        }
                        """
                        )?.typeName).to(equal(TypeName(name: "Reducer<WorkoutTemplate.State, WorkoutTemplate.Action, GlobalEnvironment<Programs.Environment>>")))
                    }

                    it("extracts property with literal value correctrly") {
                        expect(variable("var name = 1")?.typeName).to(equal(TypeName(name: "Int")))
                        expect(variable("var name = 1.0")?.typeName).to(equal(TypeName(name: "Double")))
                        expect(variable("var name = \"1\"")?.typeName).to(equal(TypeName(name: "String")))
                        expect(variable("var name = true")?.typeName).to(equal(TypeName(name: "Bool")))
                        expect(variable("var name = false")?.typeName).to(equal(TypeName(name: "Bool")))
                        expect(variable("var name = nil")?.typeName).to(equal(TypeName(name: "Optional")))
                        expect(variable("var name = Optional.none")?.typeName).to(equal(TypeName(name: "Optional")))
                        expect(variable("var name = Optional.some(1)")?.typeName).to(equal(TypeName(name: "Optional")))
                        expect(variable("var name = Foo.Bar()")?.typeName).to(equal(TypeName(name: "Foo.Bar")))
                    }

                    it("extracts property with array literal value correctly") {
                        expect(variable("var name = [Int]()")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(variable("var name = [1]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(variable("var name = [1, 2]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                        expect(variable("var name = [1, \"a\"]")?.typeName).to(equal(TypeName.buildArray(of: .Any)))
                        expect(variable("var name = [1, nil]")?.typeName).to(equal(TypeName.buildArray(of: TypeName.Int.asOptional)))
                        expect(variable("var name = [1, [1, 2]]")?.typeName).to(equal(TypeName.buildArray(of: .Any)))
                        expect(variable("var name = [[1, 2], [1, 2]]")?.typeName).to(equal(TypeName.buildArray(of: TypeName.buildArray(of: .Int))))
                        expect(variable("var name = [Int()]")?.typeName).to(equal(TypeName.buildArray(of: .Int)))
                    }

                    it("extracts property with dictionary literal value correctly") {
                        expect(variable("var name = [Int: Int]()")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(variable("var name = [1: 2]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(variable("var name = [1: 2, 2: 3]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Int)))
                        expect(variable("var name = [1: 1, 2: \"a\"]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Any)))
                        expect(variable("var name = [1: 1, 2: nil]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: TypeName.Int.asOptional)))
                        expect(variable("var name = [1: 1, 2: [1, 2]]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .Any)))
                        expect(variable("var name = [[1: 1, 2: 2], [1: 1, 2: 2]]")?.typeName).to(equal(TypeName.buildArray(of: .buildDictionary(key: .Int, value: .Int))))
                        expect(variable("var name = [1: [1: 1, 2: 2], 2: [1: 1, 2: 2]]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .buildDictionary(key: .Int, value: .Int))))
                        expect(variable("var name = [Int(): String()]")?.typeName).to(equal(TypeName.buildDictionary(key: .Int, value: .String)))
                    }

                    it("matches inference with parser tuple") {
                        let infer = variable("var name = (1, b: \"[2,3]\", c: 1)")?.typeName
                        let parsed = variable("var name: (Int, b: String, c: Int)")?.typeName
                        expect(infer).to(equal(parsed))
                    }

                    it("extracts property with tuple literal value correctly") {
                        expect(variable("var name = (1, 2)")?.typeName).to(equal(TypeName.buildTuple(TypeName.Int, TypeName.Int)))
                        expect(variable("var name = (1, b: \"[2,3]\", c: 1)")?.typeName).to(equal(TypeName.buildTuple(.init(name: "0", typeName: .Int), .init(name: "b", typeName: .String), .init(name: "c", typeName: .Int))))
                        expect(variable("var name = (_: 1, b: 2)")?.typeName).to(equal(TypeName.buildTuple(.init(name: "0", typeName: .Int), .init(name: "b", typeName: .Int))))
                        expect(variable("var name = ((1, 2), [\"a\": \"b\"])")?.typeName).to(equal(TypeName.buildTuple(TypeName.buildTuple(TypeName.Int, TypeName.Int), TypeName.buildDictionary(key: .String, value: .String))))
                        expect(variable("var name = ((1, 2), [1, 2])")?.typeName).to(equal(TypeName.buildTuple(TypeName.buildTuple(TypeName.Int, TypeName.Int), TypeName.buildArray(of: .Int))))
                        expect(variable("var name = ((1, 2), [\"a,b\": \"b\"])")?.typeName)
                          .to(
                            equal(TypeName.buildTuple(
                              .buildTuple(.Int, .Int),
                              .buildDictionary(key: .String, value: .String))
                            ))
                    }
                }

                it("extracts standard let property correctly") {
                    let r = variable("let name: String")
                    expect(r).to(equal(Variable(name: "name", typeName: TypeName(name: "String"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                }

                it("extracts computed property correctly") {
                    expect(variable("var name: Int { return 2 }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)))
                    expect(variable("let name: Int")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: false)))
                    expect(variable("var name: Int")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(variable("var name: Int { \nget { return 0 } \nset {} }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: true)))
                    expect(variable("var name: Int { \nget { return 0 } }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isAsync: false, throws: false)))
                    expect(variable("var name: Int { \nget async { return 0 } }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isAsync: true, throws: false)))
                    expect(variable("var name: Int { \nget throws { return 0 } }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isAsync: false, throws: true)))
                    expect(variable("var name: Int { \nget async throws { return 0 } }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isAsync: true, throws: true)))
                    expect(variable("var name: Int \n{ willSet { } }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                    expect(variable("var name: Int { \ndidSet {} }")).to(equal(Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)))
                }

                it("extracts generic property correctly") {
                    expect(variable("let name: Observable<Int>")).to(equal(Variable(name: "name", typeName:
                    TypeName(name: "Observable<Int>", generic: .init(name: "Observable", typeParameters: [.init(typeName: TypeName(name: "Int"))])
                    ), accessLevel: (read: .internal, write: .none), isComputed: false)))

                    expect(variable("let name: Combine.Observable<Int>")).to(equal(Variable(name: "name", typeName:
                    TypeName(name: "Combine.Observable<Int>", generic: .init(name: "Combine.Observable", typeParameters: [.init(typeName: TypeName(name: "Int"))])
                    ), accessLevel: (read: .internal, write: .none), isComputed: false)))
                }

                context("given it has sourcery annotations") {

                    it("extracts single annotation") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)

                        expect(variable("// sourcery: skipEquability\n" +
                                             "var name: Int { return 2 }")).to(equal(expectedVariable))
                    }

                    it("extracts multiple annotations on the same line") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)
                        expectedVariable.annotations["jsonKey"] = "json_key" as NSString

                        expect(variable("// sourcery: skipEquability, jsonKey = \"json_key\"\n" +
                                             "var name: Int { return 2 }")).to(equal(expectedVariable))
                    }

                    it("extracts multi-line annotations, including numbers") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)
                        expectedVariable.annotations["jsonKey"] = "json_key" as NSString
                        expectedVariable.annotations["thirdProperty"] = NSNumber(value: -3)

                        let result = variable(        "// sourcery: skipEquability, jsonKey = \"json_key\"\n" +
                                                           "// sourcery: thirdProperty = -3\n" +
                                                           "var name: Int { return 2 }")
                        expect(result).to(equal(expectedVariable))
                    }

                    it("extracts annotations interleaved with comments") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["isSet"] = NSNumber(value: true)
                        expectedVariable.annotations["numberOfIterations"] = NSNumber(value: 2)
                        expectedVariable.documentation = ["isSet is used for something useful"]

                        let result = variable(        "// sourcery: isSet\n" +
                                                           "/// isSet is used for something useful\n" +
                                                           "// sourcery: numberOfIterations = 2\n" +
                                                           "var name: Int { return 2 }",
                                                      parseDocumentation: true)
                        expect(result).to(equal(expectedVariable))
                    }

                    it("stops extracting annotations if it encounters a non-comment line") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["numberOfIterations"] = NSNumber(value: 2)

                        let result = variable(        "// sourcery: isSet\n" +
                                                           "\n" +
                                                           "// sourcery: numberOfIterations = 2\n" +
                                                           "var name: Int { return 2 }")
                        expect(result).to(equal(expectedVariable))
                    }

                    it("separates comments correctly from variable name") {
                        let result = variable(
"""
@SomeWrapper
var variable2 // some comment
""")
                        let expectedVariable = Variable(name: "variable2", typeName: TypeName(name: "UnknownTypeSoAddTypeAttributionToVariable"), accessLevel: (read: .internal, write: .internal), isComputed: false, attributes: ["SomeWrapper": [Attribute(name: "SomeWrapper", arguments: [:])]])
                        expect(result).to(equal(expectedVariable))
                    }
                    
                    it("extracts trailing annotations") {
                        let expectedVariable = Variable(name: "name", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true)
                        expectedVariable.annotations["jsonKey"] = "json_key" as NSString
                        expectedVariable.annotations["skipEquability"] = NSNumber(value: true)

                        expect(variable("// sourcery: jsonKey = \"json_key\"\nvar name: Int { return 2 } // sourcery: skipEquability")).to(equal(expectedVariable))
                    }
                }
            }
        }
    }
}
