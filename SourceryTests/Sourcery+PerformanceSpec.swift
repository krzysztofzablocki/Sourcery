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

    func testParsingPerformance() {
        self.measure {
            let _ = try? Sourcery().processFiles(Stubs.sourceForPerformance,
                                                 usingTemplates: Stubs.templateDirectory + Path("Basic.stencil"),
                                                 output: self.outputDir)
        }
    }
}
