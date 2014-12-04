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
        let context = Context(Box("success"))
        let box = context.boxedValueForMustacheExpression(".")!
        let string: String! = box.value()
        XCTAssertEqual(string, "success")
    }
    
    func testIdentifierExpression() {
        let context = Context(Box(["name": "success"]))
        let box = context.boxedValueForMustacheExpression("name")!
        let string: String! = box.value()
        XCTAssertEqual(string, "success")
    }
    
    func testScopedExpression() {
        let context = Context(Box(["a": ["name": "success"]]))
        let box = context.boxedValueForMustacheExpression("a.name")!
        let string: String! = box.value()
        XCTAssertEqual(string, "success")
    }
    
    func testFilteredExpression() {
        let filterValue = BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box in
            return Box(string!.uppercaseString)
        })
        let context = Context(Box(["name": Box("success"), "f": filterValue]))
        let box = context.boxedValueForMustacheExpression("f(name)")!
        let string: String! = box.value()
        XCTAssertEqual(string, "SUCCESS")
    }

    func testParseError() {
        let context = Context()
        var error: NSError? = nil
        let box = context.boxedValueForMustacheExpression("a.", error: &error)
        XCTAssertNil(box)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)  // Invalid expression
    }
    
    func testRenderingError() {
        let context = Context()
        var error: NSError? = nil
        let box = context.boxedValueForMustacheExpression("f(x)", error: &error)
        XCTAssertNil(box)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)  // Missing filter
    }
}
