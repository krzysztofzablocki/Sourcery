//
// Created by Ruslan Alikhamov on 02/07/2023.
// Copyright (c) 2023 Evolutions - FZCO. All rights reserved.
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

class StringViewSpec: QuickSpec {
    override func spec() {
        describe("StringView") {
            describe("init()") {
                func instantiate(_ content: String) -> [Line] {
                    return StringView.init(content).lines
                }

                it("parses correct number of lines when utf8 comments are present") {
                    let lines = instantiate("protocol AgeModel {\r\n    var ageDesc: String { get } // 年龄的描述\r\n}\r\n")
                    expect(lines.count).to(equal(4))
                }

                it("parses correct number of lines when \r\n newline symbols are present") {
                    let lines = instantiate("'struct S {}\r\nprotocol AP {}\r\n")
                    expect(lines.count).to(equal(3))
                }
            }
        }
    }
}
