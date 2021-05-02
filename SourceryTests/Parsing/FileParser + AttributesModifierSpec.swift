import Quick
import Nimble
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
import SourceryFramework
import SourceryRuntime

class FileParserAttributesSpec: QuickSpec {
    override func spec() {

        describe("FileParser") {
            func parse(_ code: String) -> [Type] {
                guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                return parserResult.types
            }

            it("extracts type attribute and modifiers") {
                expect(parse("""
                             /*
                               docs
                             */
                             @objc(WAGiveRecognitionCoordinator)
                             // sourcery: AutoProtocol, AutoMockable
                             class GiveRecognitionCoordinator: NSObject {
                             }
                             """).first?.attributes).to(
                  equal(["objc": [Attribute(name: "objc", arguments: ["0": "WAGiveRecognitionCoordinator" as NSString], description: "@objc(WAGiveRecognitionCoordinator)")]])
                )

                expect(parse("class Foo { func some(param: @convention(swift) @escaping ()->()) {} }").first?.methods.first?.parameters.first?.typeAttributes).to(equal([
                    "escaping": [Attribute(name: "escaping")],
                    "convention": [Attribute(name: "convention", arguments: ["0": "swift" as NSString], description: "@convention(swift)")]
                ]))

                expect(parse("final class Foo { }").first?.modifiers).to(equal([
                    Modifier(name: "final")
                ]))

                expect(parse("@objc class Foo {}").first?.attributes).to(equal([
                    "objc": [Attribute(name: "objc", arguments: [:], description: "@objc")]
                ]))

                expect(parse("@objc(Bar) class Foo {}").first?.attributes).to(equal([
                    "objc": [Attribute(name: "objc", arguments: ["0": "Bar" as NSString], description: "@objc(Bar)")]
                ]))

                expect(parse("@objcMembers class Foo {}").first?.attributes).to(equal([
                    "objcMembers": [Attribute(name: "objcMembers", arguments: [:], description: "@objcMembers")]
                ]))

                expect(parse("public class Foo {}").first?.modifiers).to(equal([
                    Modifier(name: "public")
                ]))
            }

            context("given attribute with arguments") {
                it("extracts attribute arguments with values") {
                    expect(parse("""
                            @available(*, unavailable, renamed: \"NewFoo\")
                            protocol Foo {}
                            """
                    ).first?.attributes)
                    .to(equal([
                                "available": [Attribute(name: "available", arguments: [
                                    "0": "*" as NSString,
                                    "1": "unavailable" as NSString,
                                    "renamed": "NewFoo" as NSString
                                ], description: "@available(*, unavailable, renamed: \"NewFoo\")")
                                ]]))

                    expect(parse("""
                            @available(iOS 10.0, macOS 10.12, *)
                            protocol Foo {}
                            """
                    ).first?.attributes)
                    .to(equal([
                                "available": [Attribute(name: "available", arguments: [
                                    "0": "iOS 10.0" as NSString,
                                    "1": "macOS 10.12" as NSString,
                                    "2": "*" as NSString
                                ], description: "@available(iOS 10.0, macOS 10.12, *)")
                                ]]))
                }
            }

            it("extracts method attributes and modifiers") {
                expect(parse("class Foo { @discardableResult\n@objc(some)\nfunc some() {} }").first?.methods.first?.attributes).to(equal([
                    "discardableResult": [Attribute(name: "discardableResult")],
                    "objc": [Attribute(name: "objc", arguments: ["0": "some" as NSString], description: "@objc(some)")]
                ]))

                expect(parse("class Foo { @nonobjc convenience required init() {} }").first?.initializers.first?.attributes).to(equal([
                    "nonobjc": [Attribute(name: "nonobjc")]
                ]))

                expect(parse("class Foo { @nonobjc convenience required init() {} }").first?.initializers.first?.modifiers).to(equal([
                    Modifier(name: "convenience"),
                    Modifier(name: "required")
                ]))

                expect(parse("struct Foo { mutating func some() {} }").first?.methods.first?.modifiers).to(equal([
                    Modifier(name: "mutating")
                ]))

                expect(parse("class Foo { final func some() {} }").first?.methods.first?.modifiers).to(equal([
                    Modifier(name: "final")
                ]))

                expect(parse("@objc protocol Foo { @objc optional func some() }").first?.methods.first?.modifiers).to(equal([
                    Modifier(name: "optional")
                ]))
            }

            it("extracts method parameter attributes") {
                expect(parse("class Foo { func some(param: @escaping ()->()) {} }").first?.methods.first?.parameters.first?.typeAttributes).to(equal([
                    "escaping": [Attribute(name: "escaping")]
                ]))
            }

            it("extracts variable attributes and modifiers") {
                expect(parse("class Foo { @NSCopying @objc(objcName) var name: NSString = \"\" }").first?.variables.first?.attributes).to(equal([
                    "NSCopying": [Attribute(name: "NSCopying", description: "@NSCopying")],
                    "objc": [Attribute(name: "objc", arguments: ["0": "objcName" as NSString], description: "@objc(objcName)")]
                ]))

                expect(parse("struct Foo { mutating var some: Int }").first?.variables.first?.modifiers).to(equal([
                    Modifier(name: "mutating")
                ]))

                expect(parse("class Foo { final var some: Int }").first?.variables.first?.modifiers).to(equal([
                    Modifier(name: "final")
                ]))

                expect(parse("class Foo { lazy var name: String = \"Hello\" }").first?.variables.first?.modifiers).to(equal([
                    Modifier(name: "lazy")
                ]))

                func assertSetterAccess(_ access: String, line: UInt = #line) {
                    expect(line: line, parse("public class Foo { \(access)(set) var some: Int }").first?.variables.first?.modifiers).to(equal([
                       Modifier(name: access, detail: "set")
                    ]))
                }

                assertSetterAccess("private")
                assertSetterAccess("fileprivate")
                assertSetterAccess("internal")
                assertSetterAccess("public")

                func assertGetterAccess(_ access: String, line: UInt = #line) {
                    expect(line: line, parse("public class Foo { \(access) var some: Int }").first?.variables.first?.modifiers).to(equal([
                        Modifier(name: access)
                    ]))
                }

                assertGetterAccess("private")
                assertGetterAccess("fileprivate")
                assertGetterAccess("internal")
                assertGetterAccess("public")

            }

            it("extracts type attributes") {
                expect(parse("@nonobjc class Foo {}").first?.attributes).to(equal([
                    "nonobjc": [Attribute(name: "nonobjc")]
                ]))
            }

        }
    }
}
