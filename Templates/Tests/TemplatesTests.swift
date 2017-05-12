//
//  TemplatesTests.swift
//  TemplatesTests
//
//  Created by Anton Domashnev on 01.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation
import Quick
import Nimble

class TemplatesTests: QuickSpec {
    override func spec() {
        func check(template name: String) {
            let bundle = Bundle.init(for: type(of: self))
            guard let generatedFilePath = bundle.path(forResource: "\(name).generated", ofType: "swift"), let expectedFilePath = bundle.path(forResource: name, ofType: "expected") else {
                fatalError("Template \(name) can not be checked as the generated or expected file is not presented in the bundle")
            }
            guard let generatedFileString = try? String(contentsOfFile: generatedFilePath), let expectedFileString = try? String(contentsOfFile: expectedFilePath) else {
                fatalError("Template \(name) can not be checked as the generated or expected file can not be read")
            }
            
            let emptyLinesFilter: (String) -> Bool = { line in return !line.isEmpty }
            let commentLinesFilter: (String) -> Bool = { line in return !line.hasPrefix("//") }
            let generatedFileLines = generatedFileString.components(separatedBy: .newlines).filter(emptyLinesFilter).filter(commentLinesFilter)
            let expectedFileLines = expectedFileString.components(separatedBy: .newlines).filter(emptyLinesFilter).filter(commentLinesFilter)
            expect(generatedFileLines).to(equal(expectedFileLines))
        }
        
        describe("AutoCases template") {
            it("generates expected code") {
                check(template: "AutoCases")
            }
        }
        
        describe("AutoEquatable template") {
            it("generates expected code") {
                check(template: "AutoEquatable")
            }
        }

        describe("AutoHashable template") {
            it("generates expected code") {
                check(template: "AutoHashable")
            }
        }
    }
}
