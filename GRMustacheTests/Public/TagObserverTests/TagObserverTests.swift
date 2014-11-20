//
//  TagObserverTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TagObserverTests: XCTestCase {
    
    struct TestedTagObserver: MustacheTagObserver {
        let willRenderBlock: ((tag: Tag, value: Value) -> Value)?
        let didRenderBlock: ((tag: Tag, rendering: String?, value: Value) -> Void)?
        
        func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
            if let block = willRenderBlock {
                return block(tag: tag, value: value)
            } else {
                return value
            }
        }
        
        func mustacheTag(tag: Tag, didRender rendering: String?, forValue value: Value) {
            if let block = didRenderBlock {
                block(tag: tag, rendering: rendering, value: value)
            }
        }
    }
    
    func testMustacheTagWillRenderIsNotTriggeredByText() {
        var success = true
        let tagObserver = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            success = false
            return value
        }, didRenderBlock: nil)
        
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render(Value())!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testMustacheTagDidRenderIsNotTriggeredByText() {
        var success = true
        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: { (tag: Tag, rendering: String?, value: Value) in
            success = false
            })
        
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render(Value())!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testVariableTagDelegate() {
        var preRenderingValue: Value?
        var preRenderingTagType: TagType?
        var postRenderingValue: Value?
        var postRenderingTagType: TagType?
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            preRenderingValue = value
            preRenderingTagType = tag.type
            return Value(1)
        }
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) -> Void in
            postRenderingValue = value
            postRenderingTagType = tag.type
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "---{{foo}}---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render(Value(["foo": "value"]))!
        
        XCTAssertEqual(rendering, "---1---")
        XCTAssertEqual(preRenderingTagType!, TagType.Variable)
        XCTAssertEqual(postRenderingTagType!, TagType.Variable)
        XCTAssertEqual((preRenderingValue?.object() as String?)!, "value")
        XCTAssertEqual((postRenderingValue?.object() as Int?)!, 1)
    }
    
    func testSectionTagDelegate() {
        var preRenderingTagType: TagType?
        var postRenderingTagType: TagType?
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            preRenderingTagType = tag.type
            return value
        }
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) -> Void in
            postRenderingTagType = tag.type
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "<{{#false}}{{not_rendered}}{{/false}}>")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render(Value())!
        
        XCTAssertEqual(rendering, "<>")
        XCTAssertEqual(preRenderingTagType!, TagType.Section)
        XCTAssertEqual(postRenderingTagType!, TagType.Section)
    }
}
