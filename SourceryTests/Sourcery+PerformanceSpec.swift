////
////  Sourcery+PerformanceSpec.swift
////  Sourcery
////
////  Created by Krzysztof Zabłocki on 26/12/2016.
////  Copyright © 2016 Pixle. All rights reserved.
////
//
//import XCTest
//import PathKit
//
//@testable
//import Sourcery
//
//class SourceryPerformanceSpec: XCTestCase {
//    let outputDir: Path = {
//        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SourceryPerformance") else { fatalError("Unable to get temporary path") }
//        _ = try? FileManager.default.removeItem(at: tempDirURL)
//        // swiftlint:disable:next force_try
//        try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
//        return Path(tempDirURL.path)
//    }()
//
//    func testParsingPerformance() {
//        self.measure {
//            let _ = try? Sourcery().processFiles(Stubs.sourceForPerformance,
//                                                 usingTemplates: Stubs.templateDirectory + Path("Basic.stencil"),
//                                                 output: self.outputDir)
//        }
//    }
//}
