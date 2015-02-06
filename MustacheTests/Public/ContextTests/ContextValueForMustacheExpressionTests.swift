//
//  ContextValueForMustacheExpressionTests.swift
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class ContextValueForMustacheExpressionTests: XCTestCase {

    func testImplicitIteratorExpression() {
        let context = Context(Box("success"))
        let box = context.boxForMustacheExpression(".")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testIdentifierExpression() {
        let context = Context(Box(["name": "success"]))
        let box = context.boxForMustacheExpression("name")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testScopedExpression() {
        let context = Context(Box(["a": ["name": "success"]]))
        let box = context.boxForMustacheExpression("a.name")!
        let string = box.value as? String
        XCTAssertEqual(string!, "success")
    }
    
    func testFilteredExpression() {
        let filter = Filter({ (string: String?, error: NSErrorPointer) -> MustacheBox in
            return Box(string!.uppercaseString)
        })
        let context = Context(Box(["name": Box("success"), "f": Box(filter)]))
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
