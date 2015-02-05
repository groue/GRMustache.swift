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
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString("{{name}}")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(string: "{{#name}}{{/name}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString("{{#name}}")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(string: "{{  name\t}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString("{{  name\t}}")
        XCTAssertTrue(range != nil)
    }

    func testTagDescriptionContainsLineNumber() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        var template = Template(string: "{{name}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString("line 1")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(string: "\n {{\nname}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString("line 2")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(string: "\n\n  {{#\nname}}\n\n{{/name}}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString("line 3")
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = Template(named: "TagTests", bundle: bundle)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(URL: bundle.URLForResource("TagTests", withExtension: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = templateRepository.template(named: "TagTests")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(path: bundle.pathForResource("TagTests", ofType: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = Template(named: "TagTests_wrapper", bundle: bundle)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(URL: bundle.URLForResource("TagTests_wrapper", withExtension: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: Box) -> Box in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = NSBundle(forClass: self.dynamicType)
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = templateRepository.template(named: "TagTests_wrapper")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        var range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = templateRepository.template(string: "{{> TagTests }}")!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = Template(path: bundle.pathForResource("TagTests_wrapper", ofType: "mustache")!)!
        template.baseContext = template.baseContext.extendedContext(boxValue(willRender))
        template.render()
        range = tagDescription?.rangeOfString(bundle.pathForResource("TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
}
