import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class FileParserAttributesSpec: QuickSpec {
    override func spec() {

        describe("FileParser") {

            guard let sut: FileParser = try? FileParser(contents: "") else { return fail() }

            func parse(_ code: String) -> [Type] {
                guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                return Composer().uniqueTypes(parserResult)
            }

            it("extracts type attributes") {
                expect(sut.parseTypeAttributes("@autoclosure @convention(swift) @escaping (@escaping ()->())->()"))
                    .to(equal([
                        "escaping": Attribute(name: "escaping"),
                        "convention": Attribute(name: "convention", arguments: ["swift": NSNumber(value: true)], description: "@convention(swift)"),
                        "autoclosure": Attribute(name: "autoclosure")
                        ]))

                expect(parse("final class Foo { }").first?.attributes).to(equal([
                    "final": Attribute(name: "final", description: "final")
                    ]))

                expect(parse("@objc class Foo {}").first?.attributes).to(equal([
                    "objc": Attribute(name: "objc", arguments: [:], description: "@objc")
                    ]))

                expect(parse("@objc(Bar) class Foo {}").first?.attributes).to(equal([
                    "objc": Attribute(name: "objc", arguments: ["name": "Bar" as NSString], description: "@objc(Bar)")
                    ]))

                expect(parse("@objcMembers class Foo {}").first?.attributes).to(equal([
                    "objcMembers": Attribute(name: "objcMembers", arguments: [:], description: "@objcMembers")
                    ]))

                expect(parse("public class Foo {}").first?.attributes).to(equal([
                    "public": Attribute(name: "public", arguments: [:], description: "public")
                    ]))
            }

            context("given attribute with arguments") {
                it("extracts attribute arguments with no values") {
                    expect(sut.parseTypeAttributes("@convention(swift) (@escaping ()->())->()"))
                        .to(equal([
                            "convention": Attribute(name: "convention", arguments: ["swift": NSNumber(value: true)], description: "@convention(swift)")
                            ]))
                }

                it("extracts attribute arguments with values") {
                    expect(sut.parseTypeAttributes("@available(*, unavailable, renamed: \"Use MyRenamedProtocol\")"))
                        .to(equal([
                            "available": Attribute(name: "available", arguments: [
                                "unavailable": NSNumber(value: true),
                                "renamed": "Use MyRenamedProtocol" as NSString
                                ], description: "@available(*, unavailable, renamed: \"Use MyRenamedProtocol\")")
                            ]))

                    expect(sut.parseTypeAttributes("@available(iOS 10.0, macOS 10.12, *)"))
                        .to(equal([
                            "available": Attribute(name: "available", arguments: [
                                "iOS_10.0": NSNumber(value: true),
                                "macOS_10.12": NSNumber(value: true)
                                ], description: "@available(iOS 10.0, macOS 10.12, *)")
                            ]))

                }
            }

            it("extracts method attributes") {
                expect(parse("class Foo { @discardableResult\n@objc(some)\nfunc some() {} }").first?.methods.first?.attributes).to(equal([
                    "discardableResult": Attribute(name: "discardableResult"),
                    "objc": Attribute(name: "objc", arguments: ["name": "some" as NSString], description: "@objc(some)")
                    ]))

                expect(parse("class Foo { @nonobjc convenience required init() {} }").first?.initializers.first?.attributes).to(equal([
                    "nonobjc": Attribute(name: "nonobjc"),
                    "convenience": Attribute(name: "convenience", description: "convenience"),
                    "required": Attribute(name: "required", description: "required")
                    ]))

                expect(parse("struct Foo { mutating func some() {} }").first?.methods.first?.attributes).to(equal([
                    "mutating": Attribute(name: "mutating", description: "mutating")
                    ]))

                expect(parse("class Foo { final func some() {} }").first?.methods.first?.attributes).to(equal([
                    "final": Attribute(name: "final", description: "final")
                    ]))
            }

            it("extracts method parameter attributes") {
                expect(parse("class Foo { func some(param: @escaping ()->()) {} }").first?.methods.first?.parameters.first?.typeAttributes).to(equal([
                    "escaping": Attribute(name: "escaping")
                    ]))
            }

            it("extracts variable attributes") {
                expect(parse("class Foo { @NSCopying @objc(objcName:) var name: String }").first?.variables.first?.attributes).to(equal([
                    "NSCopying": Attribute(name: "NSCopying", description: "@NSCopying"),
                    "objc": Attribute(name: "objc", arguments: ["name": "objcName:" as NSString], description: "@objc(objcName:)")
                    ]))

                expect(parse("struct Foo { mutating var some: Int }").first?.variables.first?.attributes).to(equal([
                    "mutating": Attribute(name: "mutating", description: "mutating")
                    ]))

                expect(parse("class Foo { final var some: Int }").first?.variables.first?.attributes).to(equal([
                    "final": Attribute(name: "final", description: "final")
                    ]))

                func assertSetterAccess(_ access: String, line: UInt = #line) {
                    expect(parse("public class Foo { \(access)(set) var some: Int }").first?.variables.first?.attributes, line: line).to(equal([
                        access: Attribute(name: access, arguments: ["set": NSNumber(value: true)], description: "\(access)(set)")
                        ]))
                }

                assertSetterAccess("private")
                assertSetterAccess("fileprivate")
                assertSetterAccess("internal")
                assertSetterAccess("public")

                func assertGetterAccess(_ access: String, line: UInt = #line) {
                    expect(parse("public class Foo { \(access) var some: Int }").first?.variables.first?.attributes, line: line).to(equal([
                        access: Attribute(name: access, arguments: [:], description: "\(access)")
                        ]))
                }

                assertSetterAccess("private")
                assertSetterAccess("fileprivate")
                assertSetterAccess("internal")
                assertSetterAccess("public")

            }

            it("extracts type attributes") {
                expect(parse("@nonobjc class Foo {}").first?.attributes).to(equal([
                    "nonobjc": Attribute(name: "nonobjc")
                ]))
            }

        }
    }
}
