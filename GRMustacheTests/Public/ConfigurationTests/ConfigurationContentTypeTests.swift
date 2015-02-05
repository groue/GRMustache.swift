//
//  ConfigurationContentTypeTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 13/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ConfigurationContentTypeTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Configuration.defaultConfiguration.contentType = .HTML
    }
    
    func testFactoryConfigurationHasHTMLContentTypeRegardlessOfDefaultConfiguration() {
        Configuration.defaultConfiguration.contentType = .HTML
        var configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
        
        Configuration.defaultConfiguration.contentType = .Text
        configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderEscapedInput() {
        Configuration.defaultConfiguration.contentType = .HTML
        let template = Template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }

    func testDefaultConfigurationContentTypeTextLHasTemplateRenderUnescapedInput() {
        Configuration.defaultConfiguration.contentType = .Text
        let template = Template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTML() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        Configuration.defaultConfiguration.contentType = .HTML
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasTemplateRenderText() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        Configuration.defaultConfiguration.contentType = .Text
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTML() {
        Configuration.defaultConfiguration.contentType = .HTML
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasSectionTagRenderText() {
        Configuration.defaultConfiguration.contentType = .Text
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTML() {
        Configuration.defaultConfiguration.contentType = .HTML
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasVariableTagRenderText() {
        Configuration.defaultConfiguration.contentType = .Text
        
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
        template.render(Box(render: render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testPragmaContentTypeTextOverridesDefaultConfiguration() {
        Configuration.defaultConfiguration.contentType = .HTML
        let template = Template(string:"{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesDefaultConfiguration() {
        Configuration.defaultConfiguration.contentType = .Text
        let template = Template(string:"{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationContentType() {
        Configuration.defaultConfiguration.contentType = .HTML
        var repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.HTML)
        
        Configuration.defaultConfiguration.contentType = .Text
        repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.Text)
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }

    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        Configuration.defaultConfiguration.contentType = .HTML
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        Configuration.defaultConfiguration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        Configuration.defaultConfiguration.contentType = .Text
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        Configuration.defaultConfiguration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")!
        let rendering = template.render(boxValue("&"))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled() {
        // TODO: import test from GRMustache
    }
    
    func testDefaultConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled() {
        // TODO: import test from GRMustache
    }
    
    func testRepositoryConfigurationCanNotBeMutatedAfterATemplateHasBeenCompiled() {
        // TODO: import test from GRMustache
    }
    
}
