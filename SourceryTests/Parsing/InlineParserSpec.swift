//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

extension NSRange: Equatable {
}

public func == (lhs: NSRange, rhs: NSRange) -> Bool {
    return NSEqualRanges(lhs, rhs)
}

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return Structure(file: File(contents: source)).dictionary
}

class InlineParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("InlineParser") {
            let source =
                    "// sourcery:inline:Type.AutoCoding\n" +
                    "var something: Int\n" +
                    "// sourcery:end\n"

            let result =
                    InlineParser.parse(source)

            it("tracks it") {
                expect(result.inlineRanges["Type.AutoCoding"]).to(equal(NSRange(location: 35, length: 19)))
            }

            it("removes content between the markup") {
                let expected =
                                "// sourcery:inline:Type.AutoCoding\n" +
                                "// sourcery:end\n"

                expect(result.contents).to(equal(expected))
            }
        }
    }
}
