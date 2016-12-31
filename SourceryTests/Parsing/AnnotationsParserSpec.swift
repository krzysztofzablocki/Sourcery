//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

class AnnotationsParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("AnnotationsParser") {
            describe("parse(line:)") {
                func parse(_ content: String) -> Annotations {
                    return AnnotationsParser.parse(line: content)
                }

                it("extracts single annotation") {
                    let annotations = ["skipEquability": NSNumber(value: true)]

                    expect(parse("skipEquability")).to(equal(annotations))
                }

                it("extracts multiple annotations on the same line") {
                    let annotations = ["skipEquability": NSNumber(value: true),
                                       "jsonKey": "json_key" as NSString]

                    expect(parse("skipEquability, jsonKey = \"json_key\"")).to(equal(annotations))
                }
            }
            describe("parse(content:)") {
                func parse(_ content: String) -> Annotations {
                    return AnnotationsParser(contents: content).all
                }

                it("extracts multi-line annotations, including numbers") {
                    let annotations = ["skipEquability": NSNumber(value: true),
                                       "jsonKey": "json_key" as NSString,
                                       "thirdProperty": NSNumber(value: -3)]

                    let result = parse("// sourcery: skipEquability, jsonKey = \"json_key\"\n" +
                                               "// sourcery: thirdProperty = -3\n" +
                                               "var name: Int { return 2 }")
                    expect(result).to(equal(annotations))
                }

                it("extracts annotations interleaved with comments") {
                    let annotations = ["isSet": NSNumber(value: true),
                                       "numberOfIterations": NSNumber(value: 2)]

                    let result = parse("// sourcery: isSet\n" +
                                               "/// isSet is used for something useful\n" +
                                               "// sourcery: numberOfIterations = 2\n" +
                                               "var name: Int { return 2 }")
                    expect(result).to(equal(annotations))
                }
            }
        }
    }
}
