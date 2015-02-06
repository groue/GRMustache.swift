//
//  ConfigurationContentTypeTests.swift
//
//  Created by Gwendal Roué on 13/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class ConfigurationContentTypeTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        DefaultConfiguration = Configuration()
    }
    
    
    func testFactoryConfigurationHasHTMLContentTypeRegardlessOfDefaultConfiguration() {
        DefaultConfiguration.contentType = .HTML
        var configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
        
        DefaultConfiguration.contentType = .Text
        configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderEscapedInput() {
        DefaultConfiguration.contentType = .HTML
        let template = Template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }

    func testDefaultConfigurationContentTypeTextLHasTemplateRenderUnescapedInput() {
        DefaultConfiguration.contentType = .Text
        let template = Template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTML() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        DefaultConfiguration.contentType = .HTML
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = testedTemplate.render(info, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasTemplateRenderText() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        DefaultConfiguration.contentType = .Text
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = testedTemplate.render(info, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTML() {
        DefaultConfiguration.contentType = .HTML
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{#.}}{{/.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasSectionTagRenderText() {
        DefaultConfiguration.contentType = .Text
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{#.}}{{/.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTML() {
        DefaultConfiguration.contentType = .HTML
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasVariableTagRenderText() {
        DefaultConfiguration.contentType = .Text
        
        let testedTemplate = Template(string: "")!
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context, error: error)
            if let rendering = rendering {
                testedContentType = rendering.contentType
            }
            return rendering
        }
        
        let template = Template(string: "{{.}}")!
        template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testPragmaContentTypeTextOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .HTML
        let template = Template(string:"{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .Text
        let template = Template(string:"{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationContentType() {
        DefaultConfiguration.contentType = .HTML
        var repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.HTML)
        
        DefaultConfiguration.contentType = .Text
        repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.Text)
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }

    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .HTML
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .Text
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(Box("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled() {
        // TODO: import test from che
    }
    
    func testDefaultConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled() {
        // TODO: import test from che
    }
    
    func testRepositoryConfigurationCanNotBeMutatedAfterATemplateHasBeenCompiled() {
        // TODO: import test from che
    }
    
}
