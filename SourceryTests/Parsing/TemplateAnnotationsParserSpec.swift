//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryFramework
@testable import SourceryRuntime

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return try? Structure(file: File(contents: source)).dictionary
}

class TemplateAnnotationsParserSpec: QuickSpec {
    override func spec() {
        describe("InlineParser") {
            context("without indentation") {
                let source =
                        "// sourcery:inline:Type.AutoCoding\n" +
                        "var something: Int\n" +
                        "// sourcery:end\n"

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source)

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 35, length: 19)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal([""]))
                }

                it("removes content between the markup") {
                    expect(result.contents).to(equal(
                        "// sourcery:inline:Type.AutoCoding\n" +
                        "// sourcery:end\n"
                    ))
                }
            }

            context("with indentation") {
                let source =
                        "    // sourcery:inline:Type.AutoCoding\n" +
                        "    var something: Int\n" +
                        "    // sourcery:end\n"

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source)

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 39, length: 23)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal(["    "]))
                }

                it("removes content between the markup") {
                    expect(result.contents).to(equal(
                        "    // sourcery:inline:Type.AutoCoding\n" +
                        "    // sourcery:end\n"
                    ))
                }
            }
        }
    }
}
