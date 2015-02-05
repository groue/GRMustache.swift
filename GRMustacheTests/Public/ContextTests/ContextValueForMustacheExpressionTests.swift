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
        let context = Context(boxValue("success"))
        let box = context.boxForMustacheExpression(".")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testIdentifierExpression() {
        let context = Context(boxValue(["name": "success"]))
        let box = context.boxForMustacheExpression("name")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testScopedExpression() {
        let context = Context(boxValue(["a": ["name": "success"]]))
        let box = context.boxForMustacheExpression("a.name")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testFilteredExpression() {
        let filter = Filter({ (string: String?, error: NSErrorPointer) -> Box in
            return boxValue(string!.uppercaseString)
        })
        let context = Context(boxValue(["name": boxValue("success"), "f": Box(filter: filter)]))
        let box = context.boxForMustacheExpression("f(name)")!
        let string = box.value as? String
        XCTAssertEqual(string!, "SUCCESS")
    }

    func testParseError() {
        let context = Context()
        var error: NSError? = nil
        let box = context.boxForMustacheExpression("a.", error: &error)
        XCTAssertTrue(box == nil)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)  // Invalid expression
    }
    
    func testRenderingError() {
        let context = Context()
        var error: NSError? = nil
        let box = context.boxForMustacheExpression("f(x)", error: &error)
        XCTAssertTrue(box == nil)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)  // Missing filter
    }
}
