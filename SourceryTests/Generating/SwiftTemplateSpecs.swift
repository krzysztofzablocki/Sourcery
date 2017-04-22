//
//  SwiftTemplateSpecs.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import Quick
import Nimble
import PathKit
@testable import Sourcery

class SwiftTemplateTests: QuickSpec {
    override func spec() {
        describe("SwiftTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()

            let templatePath = Stubs.swiftTemplates + Path("Equality.swifttemplate")
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

            it("generates correct output") {
                expect { try Sourcery(cacheDisabled: true).processFiles(.sources([Stubs.sourceDirectory]), usingTemplates: [templatePath], output: outputDir) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("rethrows template parsing errors") {
                let templatePath = Stubs.swiftTemplates + Path("Invalid.swifttemplate")
                expect {
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        let path = Path.cleanTemporaryDir(name: "build") + "main.swift"
                        expect("\(error)").to(equal("\(path):4:3: error: use of unresolved identifier \'invalid\'\n  invalid \n  ^~~~~~~\n"))
                    }))
            }

            it("rethrows template runtime errors") {
                let templatePath = Stubs.swiftTemplates + Path("Runtime.swifttemplate")
                expect {
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath): Unknown type Some, should be used with `based`"))
                    }))
            }
        }
    }
}
