//
//  JeffMustPassTests.swift
//  
//
//  Created by Apple Inc. on 7/10/23.
//

import XCTest
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
import SourceryFramework
import SourceryRuntime


class JeffMustPassTests: XCTestCase {
    func testInoutFunctionParameter() {
        
        let code = """
        public func test(a: inout String)
        """
        
        guard let parserResult = try? makeParser(for: code).parse() else { XCTFail(); return }
    
        XCTAssertEqual(parserResult.functions.first!.name, "test(a: inout String)")
    }
    
    func testAttributedOptionalClosureTypeName() {
        XCTAssertEqual(
            typeName("(@_Concurrency.MainActor () async throws -> Swift.Void)?").asSource,
            "(@_Concurrency.MainActor () async throws -> Swift.Void)?"
        )
    }
    
    func testExtraDecoratedTypeName() {
        XCTAssertEqual(
            typeName("__shared Swift.String?").asSource,
            "__shared Swift.String?"
        )
    }
    
    func testInOutTypeName() {
        XCTAssertEqual(
            typeName("inout String").asSource,
            "inout String"
        )
    }
    
    func testAttributedClosureTypeName() {
        XCTAssertEqual(
            typeName("@escaping () async throws -> Swift.Void").asSource,
            "@escaping () async throws -> Swift.Void"
        )
    }
    
    func testEllipsesTypeName() {
        let code = """
        public func test(a: Int...)
        """
        
        guard let parserResult = try? makeParser(for: code).parse() else { XCTFail(); return }
    
        XCTAssertEqual(parserResult.functions.first!.name, "test(a: Int...)")
    }
    
    func testImplicitlyUnwrappedTypeName() {
        XCTAssertEqual(
            typeName("Int!").asSource,
            "Int!"
        )
    }
    
    func typeName(_ code: String) -> TypeName {
        let wrappedCode =
          """
          func test(a: \(code))
          """
        guard let parser = try? makeParser(for: wrappedCode) else { XCTFail(); return TypeName(name: "") }
        let result = try? parser.parse()
        let parameter = result?.functions.first?.parameters.first
        return parameter?.typeName ?? TypeName(name: "")
    }
}
