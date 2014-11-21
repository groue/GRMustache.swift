//
//  TagTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 21/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TagTests: XCTestCase {

    func testTagDescriptionContainsTagToken() {
        class TagDescriptionObserver: MustacheTagObserver {
            var tagDescription: String?
            init() {
                tagDescription = nil
            }
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                tagDescription = tag.description
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue value: Value) {
            }
        }
        let tagObserver = TagDescriptionObserver()
        
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        var range = tagObserver.tagDescription?.rangeOfString("{{name}}")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "{{#name}}{{/name}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        range = tagObserver.tagDescription?.rangeOfString("{{#name}}")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "{{  name\t}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        range = tagObserver.tagDescription?.rangeOfString("{{  name\t}}")
        XCTAssertTrue(range != nil)
    }

    func testTagDescriptionContainsLineNumber() {
        class TagDescriptionObserver: MustacheTagObserver {
            var tagDescription: String?
            init() {
                tagDescription = nil
            }
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                tagDescription = tag.description
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue value: Value) {
            }
        }
        let tagObserver = TagDescriptionObserver()
        
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        var range = tagObserver.tagDescription?.rangeOfString("line 1")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "\n {{\nname}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        range = tagObserver.tagDescription?.rangeOfString("line 2")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "\n\n  {{#\nname}}\n\n{{/name}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        template.render(Value())
        range = tagObserver.tagDescription?.rangeOfString("line 3")
        XCTAssertTrue(range != nil)
    }
}
