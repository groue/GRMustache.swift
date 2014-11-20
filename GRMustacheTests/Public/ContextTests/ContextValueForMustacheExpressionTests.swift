//
//  ContextValueForMustacheExpressionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ContextValueForMustacheExpressionTests: XCTestCase {

    func testImplicitIteratorExpression() {
        let context = Context(Value("success"))
        let value = context.valueForMustacheExpression(".")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testIdentifierExpression() {
        let context = Context(Value(["name": "success"]))
        let value = context.valueForMustacheExpression("name")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testScopedExpression() {
        let context = Context(Value(["a": ["name": "success"]]))
        let value = context.valueForMustacheExpression("a.name")!
        let string: String! = value.object()
        XCTAssertEqual(string, "success")
    }
    
    func testFilteredExpression() {
        let filterValue = Value({ (string: String?) -> (Value) in
            return Value(string!.uppercaseString)
        })
        let context = Context(Value(["name": Value("success"), "f": filterValue]))
        let value = context.valueForMustacheExpression("f(name)")!
        let string: String! = value.object()
        XCTAssertEqual(string, "SUCCESS")
    }

    func testParseError() {
        let context = Context()
        var error: NSError? = nil
        let value = context.valueForMustacheExpression("a.", error: &error)
        XCTAssertNil(value)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)  // Invalid expression
    }
    
    func testRenderingError() {
        let context = Context()
        var error: NSError? = nil
        let value = context.valueForMustacheExpression("f(x)", error: &error)
        XCTAssertNil(value)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)  // Missing filter
    }
}
