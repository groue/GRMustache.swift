//
//  ContextTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 17/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ContextTests: XCTestCase {
    
    func testContextConstructor() {
        let template = Template(string: "{{uppercase(foo)}}")!
        let box = Box(["foo": "bar"])
        
        var rendering = template.render(box)
        XCTAssertEqual(rendering!, "BAR")
        
        template.baseContext = Context()
        var error: NSError?
        rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testContextWithValueConstructor() {
        let template = Template(string: "{{foo}}")!
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "")
        
        let box = Box(["foo": "bar"])
        template.baseContext = Context(box)
        rendering = template.render()!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testContextWithProtectedObjectConstructor() {
        // TODO: import test from GRMustache
    }
    
    func testContextWithWillRenderFunction() {
        var success = false
        let willRender = { (tag: Tag, box: Box) -> Box in
            success = true
            return box
        }
        let template = Template(string: "{{success}}")!
        template.baseContext = Context(Box(willRender: willRender))
        template.render()
        XCTAssertTrue(success)
    }
    
    func testTopMustacheValue() {
        var context = Context()
        XCTAssertTrue(context.topBox.isEmpty)
        
        context = context.extendedContext(Box("object"))
        XCTAssertEqual((context.topBox.value as String), "object")
        
        // TODO: import protected test from GRMustacheContextTopMustacheObjectTest.testTopMustacheObject
        
        let willRender = { (tag: Tag, box: Box) -> Box in
            return box
        }
        context = context.extendedContext(Box(willRender: willRender))
        XCTAssertEqual(context.topBox.value as String, "object")

        context = context.extendedContext(Box("object2"))
        XCTAssertEqual(context.topBox.value as String, "object2")
    }
    
    func testSubscript() {
        let context = Context(Box(["name": "name1", "a": ["name": "name2"]]))
        
        // '.' is an expression, not a key
        XCTAssertTrue(context["."].isEmpty)
        
        // 'name' is a key
        XCTAssertEqual(context["name"].value as String, "name1")
        
        // 'a.name' is an expression, not a key
        XCTAssertTrue(context["a.name"].isEmpty)
    }
}
