//
//  TemplatesAnnotationParser+ForceParseInlineCodeSpec.swift
//  SourceryTests
//
//  Created by Ranvir Prasad on 07/04/20.
//  Copyright © 2020 Pixle. All rights reserved.
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

class TemplatesAnnotationParserPassInlineCodeSpec: QuickSpec {
    override func spec() {
        describe("InlineParser") {
            context("without indentation") {
                let source = """
                    // sourcery:inline:Type.AutoCoding
                        var something: Int
                    // sourcery:end
                    """

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source, aggregate: false, forceParse: ["AutoCoding"])

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 35, length: 19)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal([""]))
                }

                it("does not remove content between the markup when force parse parameter is set to template name") {
                    expect(result.contents).to(equal(
                        "// sourcery:inline:Type.AutoCoding\n" +
                            "var something: Int\n" +
                        "// sourcery:end\n"
                    ))
                }
            }

            context("with indentation") {
                let source = """
                        // sourcery:inline:Type.AutoCoding
                            var something: Int
                        // sourcery:end
                    """

                let result = TemplateAnnotationsParser.parseAnnotations("inline", contents: source, aggregate: false, forceParse: ["AutoCoding"])

                it("tracks it") {
                    let annotatedRanges = result.annotatedRanges["Type.AutoCoding"]
                    expect(annotatedRanges?.map { $0.range }).to(equal([NSRange(location: 39, length: 23)]))
                    expect(annotatedRanges?.map { $0.indentation }).to(equal(["    "]))
                }

                it("does not remove the content between the markup when force parse parameter is set to template name") {
                    expect(result.contents).to(equal("""
                        // sourcery:inline:Type.AutoCoding
                            var something: Int
                        // sourcery:end
                    """))
                }
            }
        }
    }
}
