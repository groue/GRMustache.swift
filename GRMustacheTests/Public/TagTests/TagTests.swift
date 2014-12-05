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

    class TagDescriptionObserver: MustacheTagObserver {
        var tagDescription: String?
        init() {
            tagDescription = nil
        }
        func mustacheTag(tag: Tag, willRender box: Box) -> Box {
            tagDescription = tag.description
            return box
        }
        func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
        }
    }
    
    func testTagDescriptionContainsTagToken() {
        let tagObserver = TagDescriptionObserver()
        
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString("{{name}}")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "{{#name}}{{/name}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString("{{#name}}")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "{{  name\t}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString("{{  name\t}}")
        XCTAssertTrue(range != nil)
    }

    func testTagDescriptionContainsLineNumber() {
        let tagObserver = TagDescriptionObserver()
        
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString("line 1")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "\n {{\nname}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString("line 2")
        XCTAssertTrue(range != nil)
        
        template = Template(string: "\n\n  {{#\nname}}\n\n{{/name}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString("line 3")
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedTemplatePath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        template = Template(named: "TagTests", bundle: bundle)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedTemplatePath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = Template(URL: bundle.URLForResource("TagTests", withExtension: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedTemplatePath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = Template(path: bundle.pathForResource("TagTests", ofType: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedPartialPath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        template = Template(named: "TagTests_wrapper", bundle: bundle)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedPartialPath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = Template(URL: bundle.URLForResource("TagTests_wrapper", withExtension: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedPartialPath() {
        let tagObserver = TagDescriptionObserver()
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        var range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        template = Template(path: bundle.pathForResource("TagTests_wrapper", ofType: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
        template.render()
        range = tagObserver.tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
}
