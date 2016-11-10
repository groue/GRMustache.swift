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

class ConfigurationTagDelimitersTests: XCTestCase {
   
    override func tearDown() {
        super.tearDown()
        DefaultConfiguration = Configuration()
    }
        
    func testFactoryConfigurationHasTagDelimitersRegardlessOfDefaultConfiguration() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        let configuration = Configuration()
        XCTAssertEqual(configuration.tagDelimiterPair.0, "{{")
        XCTAssertEqual(configuration.tagDelimiterPair.1, "}}")
    }
    
    func testDefaultConfigurationTagDelimiters() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        let template = try! Template(string: "<%subject%>")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesDefaultConfigurationDelimiters() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        let template = try! Template(string: "<%=[[ ]]=%>[[subject]]")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationTagDelimiters() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        let repository = TemplateRepository()
        XCTAssertEqual(repository.configuration.tagDelimiterPair.0, "<%")
        XCTAssertEqual(repository.configuration.tagDelimiterPair.1, "%>")

        DefaultConfiguration.tagDelimiterPair = ("[[", "]]")
        XCTAssertEqual(repository.configuration.tagDelimiterPair.0, "<%")
        XCTAssertEqual(repository.configuration.tagDelimiterPair.1, "%>")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.tagDelimiterPair = ("<%", "%>")
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "<%subject%>")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagDelimiterPair = ("<%", "%>")
        
        let template = try! repository.template(string: "<%subject%>")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        var configuration = Configuration()
        configuration.tagDelimiterPair = ("[[", "]]")
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "[[subject]]")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        
        let repository = TemplateRepository()
        repository.configuration.tagDelimiterPair = ("[[", "]]")
        
        let template = try! repository.template(string: "[[subject]]")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.tagDelimiterPair = ("<%", "%>")
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = try! repository.template(string: "<%=[[ ]]=%>[[subject]]")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagDelimiterPair = ("<%", "%>")
        
        let template = try! repository.template(string: "<%=[[ ]]=%>[[subject]]")
        let rendering = try! template.render(["subject": "---"])
        XCTAssertEqual(rendering, "---")
    }
    
    func testDefaultConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{foo}}<%foo%>").render(["foo": "foo"])
        XCTAssertEqual(rendering, "foo<%foo%>")
        
        DefaultConfiguration.tagDelimiterPair = ("<%", "%>")
        rendering = try! repository.template(string: "{{foo}}<%foo%>").render(["foo": "foo"])
        XCTAssertEqual(rendering, "foo<%foo%>")
    }
    
    func testRepositoryConfigurationMutationHasNoEffectAfterAnyTemplateHasBeenCompiled() {
        let repository = TemplateRepository()
        
        var rendering = try! repository.template(string: "{{foo}}<%foo%>").render(["foo": "foo"])
        XCTAssertEqual(rendering, "foo<%foo%>")
        
        repository.configuration.tagDelimiterPair = ("<%", "%>")
        rendering = try! repository.template(string: "{{foo}}<%foo%>").render(["foo": "foo"])
        XCTAssertEqual(rendering, "foo<%foo%>")
        
        var configuration = Configuration()
        configuration.tagDelimiterPair = ("<%", "%>")
        repository.configuration = configuration
        rendering = try! repository.template(string: "{{foo}}<%foo%>").render(["foo": "foo"])
        XCTAssertEqual(rendering, "foo<%foo%>")
    }
}
