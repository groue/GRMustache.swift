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
        DefaultConfiguration.contentType = .html
        var configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.html)
        
        DefaultConfiguration.contentType = .text
        configuration = Configuration()
        XCTAssertEqual(configuration.contentType, ContentType.html)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderEscapedInput() {
        DefaultConfiguration.contentType = .html
        let template = try! Template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }

    func testDefaultConfigurationContentTypeTextLHasTemplateRenderUnescapedInput() {
        DefaultConfiguration.contentType = .text
        let template = try! Template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTML() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        DefaultConfiguration.contentType = .html
        
        let testedTemplate = try! Template(string: "")
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try testedTemplate.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.html)
    }
    
    func testDefaultConfigurationContentTypeTextHasTemplateRenderText() {
        // Templates tell if they render HTML or Text via their
        // render(RenderingInfo) method.
        //
        // There is no public way to build a RenderingInfo.
        //
        // Thus we'll use a rendering object that will provide us with one:
        
        DefaultConfiguration.contentType = .text
        
        let testedTemplate = try! Template(string: "")
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try testedTemplate.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTML() {
        DefaultConfiguration.contentType = .html
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{#.}}{{/.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.html)
    }
    
    func testDefaultConfigurationContentTypeTextHasSectionTagRenderText() {
        DefaultConfiguration.contentType = .text
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{#.}}{{/.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.text)
    }
    
    func testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTML() {
        DefaultConfiguration.contentType = .html
        
        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.html)
    }
    
    func testDefaultConfigurationContentTypeTextHasVariableTagRenderText() {
        DefaultConfiguration.contentType = .text
        

        var testedContentType: ContentType?
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try info.tag.render(info.context)
            testedContentType = rendering.contentType
            return rendering
        }
        
        let template = try! Template(string: "{{.}}")
        _ = try! template.render(render)
        XCTAssertEqual(testedContentType!, ContentType.text)
    }
    
    func testPragmaContentTypeTextOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .html
        let template = try! Template(string:"{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesDefaultConfiguration() {
        DefaultConfiguration.contentType = .text
        let template = try! Template(string:"{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationContentType() {
        DefaultConfiguration.contentType = .html
        var repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.html)
        
        DefaultConfiguration.contentType = .text
        repo = TemplateRepository()
        XCTAssertEqual(repo.configuration.contentType, ContentType.text)
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .html
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .html
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextHasTemplateRenderUnescapedInputWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .text
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }

    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .html
        var configuration = Configuration()
        configuration.contentType = .text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .html
        let repository = TemplateRepository()
        repository.configuration.contentType = .text
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.contentType = .text
        var configuration = Configuration()
        configuration.contentType = .html
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.contentType = .text
        let repository = TemplateRepository()
        repository.configuration.contentType = .html
        let template = try! repository.template(string: "{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .html
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeTextOverridesRepositoryConfigurationContentTypeHTMLWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .html
        let template = try! repository.template(string: "{{%CONTENT_TYPE:TEXT}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.contentType = .text
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = try! repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testPragmaContentTypeHTMLOverridesRepositoryConfigurationContentTypeTextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.contentType = .text
        let template = try! repository.template(string: "{{%CONTENT_TYPE:HTML}}{{.}}")
        let rendering = try! template.render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testDefaultConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{.}}").render("&")
        XCTAssertEqual(rendering, "&amp;")
        
        DefaultConfiguration.contentType = .text
        rendering = try! repository.template(string: "{{.}}").render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRepositoryConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{.}}").render("&")
        XCTAssertEqual(rendering, "&amp;")
        
        repository.configuration.contentType = .text
        rendering = try! repository.template(string: "{{.}}").render("&")
        XCTAssertEqual(rendering, "&amp;")
        
        var configuration = Configuration()
        configuration.contentType = .text
        repository.configuration = configuration
        rendering = try! repository.template(string: "{{.}}").render("&")
        XCTAssertEqual(rendering, "&amp;")
    }
}
