//
//  MustacheConfigurationTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 13/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class MustacheConfigurationTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
    }
    
    func testFactoryConfigurationHasHTMLContentTypeRegardlessOfDefaultConfiguration() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        var configuration = MustacheConfiguration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
        
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        configuration = MustacheConfiguration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderEscapedInput() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        let template = MustacheTemplate(string: "{{.}}")!
        let rendering = template.render(MustacheValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }

    func testDefaultConfigurationContentTypeTextLHasTemplateRenderUnescapedInput() {
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        let template = MustacheTemplate(string: "{{.}}")!
        let rendering = template.render(MustacheValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTML() {
        // Templates tell if they render HTML or text via their
        // render(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
        // method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = testedTemplate.render(renderingInfo, contentType: contentType, error:error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasTemplateRenderText() {
        // Templates tell if they render HTML or text via their
        // render(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
        // method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = testedTemplate.render(renderingInfo, contentType: contentType, error:error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTML() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = tag.renderContent(renderingInfo, contentType: contentType, error: error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{#.}}{{/.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasSectionTagRenderText() {
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = tag.renderContent(renderingInfo, contentType: contentType, error: error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{#.}}{{/.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTML() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = tag.renderContent(renderingInfo, contentType: contentType, error: error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasVariableTagRenderText() {
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        
        let testedTemplate = MustacheTemplate(string: "")!
        var templateContentType: ContentType = .HTML
        var templateContentTypeDefined = false
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
            let rendering = tag.renderContent(renderingInfo, contentType: contentType, error: error)
            templateContentType = contentType.memory
            templateContentTypeDefined = true
            return nil
        }
        
        let template = MustacheTemplate(string: "{{.}}")!
        template.render(MustacheValue(renderable))
        XCTAssertTrue(templateContentTypeDefined)
        XCTAssertEqual(templateContentType, ContentType.Text)
    }
    
    func testPragmaContentTypeTextOverridesDefaultConfiguration() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        let template = MustacheTemplate(string:"{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(MustacheValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesDefaultConfiguration() {
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        let template = MustacheTemplate(string:"{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(MustacheValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationContentType() {
        MustacheConfiguration.defaultConfiguration.contentType = .HTML
        var repo = MustacheTemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.HTML)
        
        MustacheConfiguration.defaultConfiguration.contentType = .Text
        repo = MustacheTemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.Text)
    }
}
