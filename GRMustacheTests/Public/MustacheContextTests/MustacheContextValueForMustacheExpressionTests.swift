//
//  MustacheContextValueForMustacheExpressionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest;
import GRMustache;

class MustacheContextValueForMustacheExpressionTests: XCTestCase {

    func testImplicitIteratorExpression() {
        let context = MustacheContext(MustacheValue("success"))
        let value = context.valueForMustacheExpression(expression: ".")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testIdentifierExpression() {
        let context = MustacheContext(MustacheValue(["name": "success"]))
        let value = context.valueForMustacheExpression(expression: "name")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testScopedExpression() {
        let context = MustacheContext(MustacheValue(["a": ["name": "success"]]))
        let value = context.valueForMustacheExpression(expression: "a.name")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testFilteredExpression() {
        let filterValue = MustacheValue({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string!.uppercaseString)
        })
        let context = MustacheContext(MustacheValue(["name": MustacheValue("success"), "f": filterValue]))
        let value = context.valueForMustacheExpression(expression: "f(name)")!
        let string: String! = value.object()
        XCTAssertEqual(string, "SUCCESS")
    }

    func testParseError() {
        let context = MustacheContext()
        var error: NSError? = nil
        let value = context.valueForMustacheExpression(expression: "a.", error: &error)
        XCTAssertNil(value)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)  // Invalid expression
    }
    
    func testRenderingError() {
        let context = MustacheContext()
        var error: NSError? = nil
        let value = context.valueForMustacheExpression(expression: "f(x)", error: &error)
        XCTAssertNil(value)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)  // Missing filter
    }
}
