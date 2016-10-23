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

class ConfigurationBaseContextTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        DefaultConfiguration = Configuration()
    }
    
    func testDefaultConfigurationCustomBaseContext() {
        DefaultConfiguration.baseContext = Context(["foo": "success"])
        
        let template = try! Template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesDefaultConfigurationBaseContext() {
        DefaultConfiguration.baseContext = Context(["foo": "failure"])
        
        let template = try! Template(string: "{{foo}}")
        template.baseContext = Context(["foo": "success"])
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext() {
        DefaultConfiguration.baseContext = Context(["foo": "success"])
        
        let repository = TemplateRepository()
        let template = try! repository.template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.baseContext = Context(["foo": "success"])
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(["foo": "success"])
        
        let template = try! repository.template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.baseContext = Context(["foo": "failure"])
        
        var configuration = Configuration()
        configuration.baseContext = Context(["foo": "success"])
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.baseContext = Context(["foo": "failure"])
        
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(["foo": "success"])
        
        let template = try! repository.template(string: "{{foo}}")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.baseContext = Context(["foo": "failure"])
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "{{foo}}")
        template.baseContext = Context(["foo": "success"])
        
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(["foo": "failure"])
        
        let template = try! repository.template(string: "{{foo}}")
        template.baseContext = Context(["foo": "success"])
        
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{^foo}}success{{/foo}}").render()
        XCTAssertEqual(rendering, "success")
        
        DefaultConfiguration.baseContext = Context(["foo": "failure"])
        rendering = try! repository.template(string: "{{^foo}}success{{/foo}}").render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{^foo}}success{{/foo}}").render()
        XCTAssertEqual(rendering, "success")
        
        repository.configuration.baseContext = Context(["foo": "failure"])
        rendering = try! repository.template(string: "{{^foo}}success{{/foo}}").render()
        XCTAssertEqual(rendering, "success")
        
        var configuration = Configuration()
        configuration.baseContext = Context(["foo": "failure"])
        repository.configuration = configuration
        rendering = try! repository.template(string: "{{^foo}}success{{/foo}}").render()
        XCTAssertEqual(rendering, "success")
    }
}
