import Quick
import Nimble
import PathKit
import Foundation
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserProtocolCompositionSpec: QuickSpec {

    override func spec() {
        describe("FileParser") {
            describe("parseProtocolComposition") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return parserResult.types
                }

                it("extracts protocol compositions properly") {
                    let types = parse("""
                                            protocol Foo {
                                                func fooDo()
                                            }

                                            protocol Bar {
                                                var bar: String { get }
                                            }

                                            typealias FooBar = Foo & Bar
                                            """)
                    let protocolComp = types.first(where: { $0 is ProtocolComposition }) as? ProtocolComposition

                    expect(protocolComp).to(equal(
                        ProtocolComposition(name: "FooBar",
                                            inheritedTypes: ["Foo", "Bar"],
                                            composedTypeNames: [
                                                TypeName("Foo"),
                                                TypeName("Bar")
                                            ],
                                            composedTypes: [
                                                SourceryProtocol(name: "Foo"),
                                                SourceryProtocol(name: "Bar")
                                            ])
                    ))
                }

                it("extracts annotations on a protocol composition") {
                    let types = parse("""
                                        protocol Foo {
                                            func fooDo()
                                        }

                                        protocol Bar {
                                            var bar: String { get }
                                        }

                                        // sourcery: TestAnnotation
                                        typealias FooBar = Foo & Bar
                                        """)
                    let protocolComp = types.first(where: { $0 is ProtocolComposition }) as? ProtocolComposition

                    expect(protocolComp?.annotations).to(equal(["TestAnnotation": NSNumber(true)]))
                }
            }
        }
    }
}
