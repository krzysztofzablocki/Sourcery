/*
//
//  Sourcery+PerformanceSpec.swift
//  Sourcery
//
//  Created by Krzysztof Zabłocki on 26/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import XCTest
import PathKit

@testable
import Sourcery

class SourceryPerformanceSpec: XCTestCase {
    let outputDir: Path = {
        Path.cleanTemporaryDir(name: "SourceryPerformance")
    }()

    func testParsingPerformanceOnCleanRun() {
        let _ = try? Path.cachesDir(sourcePath: Stubs.sourceForPerformance).delete()

        self.measure {
            let _ = try? Sourcery().processFiles(Stubs.sourceForPerformance,
                                                 usingTemplates: Stubs.templateDirectory + Path("Basic.stencil"),
                                                 output: self.outputDir,
                                                 cacheDisabled: true)
        }
    }

    func testParsingPerformanceOnSubsequentRun() {
        let _ = try? Path.cachesDir(sourcePath: Stubs.sourceForPerformance).delete()
        let _ = try? Sourcery().processFiles(Stubs.sourceForPerformance,
                                             usingTemplates: Stubs.templateDirectory + Path("Basic.stencil"),
                                             output: self.outputDir)

        self.measure {
            let _ = try? Sourcery().processFiles(Stubs.sourceForPerformance,
                                                 usingTemplates: Stubs.templateDirectory + Path("Basic.stencil"),
                                                 output: self.outputDir)
        }
    }
}
*/
