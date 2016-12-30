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
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8).withoutWhitespaces

            it("generates correct output") {
                expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
            }
        }
    }
}
