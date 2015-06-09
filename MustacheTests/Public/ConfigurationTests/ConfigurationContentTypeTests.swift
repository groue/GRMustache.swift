// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
        let template = try! Template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }

    func testDefaultConfigurationContentTypeTextLHasTemplateRenderUnescapedInput() {
        DefaultConfiguration.contentType = .Text
        let template = try! Template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
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
        
        let testedTemplate = try! Template(string: "")
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try testedTemplate.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        try! template.render(Box(render))
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
        
        let testedTemplate = try! Template(string: "")
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try testedTemplate.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        try! template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTML() {
        DefaultConfiguration.contentType = .HTML
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{#.}}{{/.}}")
        try! template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasSectionTagRenderText() {
        DefaultConfiguration.contentType = .Text
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{#.}}{{/.}}")
        try! template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTML() {
        DefaultConfiguration.contentType = .HTML
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        try! template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.HTML)
    }
    
    func testDefaultConfigurationContentTypeTextHasVariableTagRenderText() {
        DefaultConfiguration.contentType = .Text
        

        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        try! template.render(Box(render))
        XCTAssertEqual(testedContentType!, ContentType.Text)
    }
    
    func testPragmaContentTypeTextOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .HTML
        let template = try! Template(string:"{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .Text
        let template = try! Template(string:"{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render(Box("&"))
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
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }

    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .HTML
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .Text
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .HTML
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .HTML
        let template = try! repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .Text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .Text
        let template = try! repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{.}}").render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
        
        DefaultConfiguration.contentType = .Text
        rendering = try! repository.template(string: "{{.}}").render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{.}}").render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
        
        repository.configuration.contentType = .Text
        rendering = try! repository.template(string: "{{.}}").render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
        
        var configuration = Configuration()
        configuration.contentType = .Text
        repository.configuration = configuration
        rendering = try! repository.template(string: "{{.}}").render(Box("&"))
        XCTAssertEqual(rendering, "&amp;")
    }
}
