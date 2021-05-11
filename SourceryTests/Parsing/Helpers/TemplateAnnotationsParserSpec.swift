//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
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

class TemplateAnnotationsParserSpec: QuickSpec {
    override func spec() {
        describe("InlineParser") {
            context("without indentation") {
                let source =
                        "// sourcery:inline:Type.AutoCoding\n" +
                        "var something: Int\n" +
                        "// sourcery:end\n"

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source, forceParse: [])

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 35, length: 19)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal([""]))
                }

                it("removes content between the markup") {
                    expect(result.contents).to(equal(
                        "// sourcery:inline:Type.AutoCoding\n" +
                        String(repeating: " ", count: 19) +
                        "// sourcery:end\n"
                    ))
                }
            }

            context("with indentation") {
                let source =
                        "    // sourcery:inline:Type.AutoCoding\n" +
                        "    var something: Int\n" +
                        "    // sourcery:end\n"

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source, forceParse: [])

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 39, length: 23)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal(["    "]))
                }

                it("removes content between the markup") {
                    expect(result.contents).to(equal(
                        "    // sourcery:inline:Type.AutoCoding\n" +
                        String(repeating: " ", count: 23) +
                        "    // sourcery:end\n"
                    ))
                }
            }
        }
    }
}
