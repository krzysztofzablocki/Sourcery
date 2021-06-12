//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

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

class AnnotationsParserSpec: QuickSpec {
    override func spec() {
        describe("AnnotationsParser") {
            describe("parse(line:)") {
                func parse(_ content: String) -> Annotations {
                    return AnnotationsParser.parse(line: content)
                }

                it("extracts single annotation") {
                    let annotations = ["skipEquality": NSNumber(value: true)]

                    expect(parse("skipEquality")).to(equal(annotations))
                }

                it("extracts repeated annotations into array") {
                    let parsedAnnotations = parse("implements = \"Service1\", implements = \"Service2\"")
                    expect(parsedAnnotations["implements"] as? [String]).to(equal(["Service1", "Service2"]))
                }

                it("extracts multiple annotations on the same line") {
                    let annotations = ["skipEquality": NSNumber(value: true),
                                       "jsonKey": "json_key" as NSString]

                    expect(parse("skipEquality, jsonKey = \"json_key\"")).to(equal(annotations))
                }
            }
            describe("parse(content:)") {
                func parse(_ content: String) -> Annotations {
                    return AnnotationsParser(contents: content).all
                }

                it("extracts inline annotations") {
                    let result = parse("//sourcery: skipDescription\n/* sourcery: skipEquality */\n/** sourcery: skipCoding */var name: Int { return 2 }")
                    expect(result).to(equal([
                        "skipDescription": NSNumber(value: true),
                        "skipEquality": NSNumber(value: true),
                        "skipCoding": NSNumber(value: true)
                        ]))
                }

                it("extracts inline annotations from multi line comments") {
                    let result = parse("//**\n*Comment\n*sourcery: skipDescription\n*sourcery: skipEquality\n*/var name: Int { return 2 }")
                    expect(result).to(equal([
                        "skipDescription": NSNumber(value: true),
                        "skipEquality": NSNumber(value: true)
                        ]))
                }

                it("extracts multi-line annotations, including numbers") {
                    let annotations = ["skipEquality": NSNumber(value: true),
                                       "placeholder": "geo:37.332112,-122.0329753?q=1 Infinite Loop" as NSString,
                                       "jsonKey": "[\"json_key\": key, \"json_value\": value]" as NSString,
                                       "thirdProperty": NSNumber(value: -3)]

                    let result = parse("// sourcery: skipEquality, jsonKey = [\"json_key\": key, \"json_value\": value]\n" +
                                               "// sourcery: thirdProperty = -3\n" +
                                               "// sourcery: placeholder = \"geo:37.332112,-122.0329753?q=1 Infinite Loop\"\n" +
                                               "var name: Int { return 2 }")
                    expect(result).to(equal(annotations))
                }

                it("extracts repeated annotations into array") {
                    let parsedAnnotations = parse("// sourcery: implements = \"Service1\"\n// sourcery: implements = \"Service2\"")
                    expect(parsedAnnotations["implements"] as? [String]).to(equal(["Service1", "Service2"]))
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

                it("extracts end of line annotations") {
                    let result = parse("// sourcery: first = 1 \n let property: Int // sourcery: second = 2, third = \"three\"")
                    expect(result).to(equal(["first": NSNumber(value: 1), "second": NSNumber(value: 2), "third": "three" as NSString]))
                }

                it("extracts end of line block comment annotations") {
                    let result = parse("// sourcery: first = 1 \n let property: Int /* sourcery: second = 2, third = \"three\" */ // comment")
                    expect(result).to(equal(["first": NSNumber(value: 1), "second": NSNumber(value: 2), "third": "three" as NSString]))
                }

                it ("ignores annotations in string literals") {
                    let result = parse("// sourcery: first = 1 \n let property = \"// sourcery: second = 2\" // sourcery: third = 3")
                    expect(result).to(equal(["first": NSNumber(value: 1), "third": NSNumber(value: 3)]))
                }

                it("extracts file annotations") {
                    let annotations = ["isSet": NSNumber(value: true)]

                    let result = parse("// sourcery:file: isSet\n" +
                        "/// isSet is used for something useful\n" +
                        "var name: Int { return 2 }")
                    expect(result).to(equal(annotations))
                }

                it("extracts namespace annotations") {
                    let annotations: [String: NSObject] = ["smth": ["key": "aKey" as NSObject, "default": NSNumber(value: 0), "prune": NSNumber(value: true)] as NSObject]
                    let result = parse("// sourcery:decoding:smth: key='aKey', default=0\n" +
                        "// sourcery:decoding:smth: prune\n" +
                        "var name: Int { return 2 }")

                    expect(result["decoding"] as? Annotations).to(equal(annotations))
                }

                it("extracts json string annotations into array") {
                    let parsedAnnotations = parse("// sourcery: theArray=\"[22,55,88]\"")
                    expect(parsedAnnotations["theArray"] as? [Int]).to(equal([22, 55, 88]))
                }

                it("extracts json string annotations into arrays of dictionaries") {
                    let parsedAnnotations = parse("// sourcery: propertyMapping=\"[{\"from\": \"lockVersion\", \"to\": \"version\"},{\"from\": \"goalStatus\", \"to\": \"status\"}]\"")
                    expect(parsedAnnotations["propertyMapping"] as? [[String: String]]).to(equal([["from": "lockVersion", "to": "version"], ["from": "goalStatus", "to": "status"]]))
                }

                it("extracts json string annotations into dictionary") {
                    let parsedAnnotations = parse("// sourcery: theDictionary=\"{\"firstValue\": 22,\"secondValue\": 55}\"")
                    expect(parsedAnnotations["theDictionary"] as? [String: Int]).to(equal(["firstValue": 22, "secondValue": 55]))
                }

                it("extracts json string annotations into dictionaries of arrays") {
                    let parsedAnnotations = parse("// sourcery: theArrays=\"{\"firstArray\":[22,55,88],\"secondArray\":[1,2,3,4]}\"")
                    expect(parsedAnnotations["theArrays"] as? [String: [Int]]).to(equal(["firstArray": [22, 55, 88], "secondArray": [1, 2, 3, 4]]))
                }
            }
        }
    }
}
