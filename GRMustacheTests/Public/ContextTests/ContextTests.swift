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
        let value = Value(["foo": "bar"])
        
        var rendering = template.render(value)
        XCTAssertEqual(rendering!, "BAR")
        
        template.baseContext = Context()
        var error: NSError?
        rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testContextWithValueConstructor() {
        let template = Template(string: "{{foo}}")!
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "")
        
        let value = Value(["foo": "bar"])
        template.baseContext = Context(value)
        rendering = template.render()!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testContextWithProtectedObjectConstructor() {
        // TODO: import test from GRMustache
    }
    
    func testContextWithTagObserverConstructor() {
        class CustomTagObserver: MustacheTagObserver {
            var success = false
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                success = true
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        
        let template = Template(string: "{{success}}")!
        let tagObserver = CustomTagObserver()
        template.baseContext = Context(tagObserver)
        template.render()
        XCTAssertTrue(tagObserver.success)
    }
    
    func testTopMustacheValue() {
        var context = Context()
        XCTAssertTrue(context.topMustacheValue.isEmpty)
        
        context = context.contextByAddingValue(Value("object"))
        XCTAssertEqual((context.topMustacheValue.object()! as String), "object")
        
        // TODO: import protected test from GRMustacheContextTopMustacheObjectTest.testTopMustacheObject
        
        class CustomTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        context = context.contextByAddingTagObserver(CustomTagObserver())
        XCTAssertEqual(context.topMustacheValue.object()! as String, "object")

        context = context.contextByAddingValue(Value("object2"))
        XCTAssertEqual(context.topMustacheValue.object()! as String, "object2")
    }
    
    func testSubscript() {
        let context = Context(Value(["name": "name1", "a": ["name": "name2"]]))
        
        // '.' is an expression, not a key
        XCTAssertTrue(context["."].isEmpty)
        
        // 'name' is a key
        XCTAssertEqual(context["name"].object()! as String, "name1")
        
        // 'a.name' is an expression, not a key
        XCTAssertTrue(context["a.name"].isEmpty)
    }
}
