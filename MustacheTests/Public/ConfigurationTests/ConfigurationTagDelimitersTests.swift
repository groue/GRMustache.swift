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
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        let configuration = Configuration()
        XCTAssertEqual(configuration.tagStartDelimiter, "{{")
        XCTAssertEqual(configuration.tagEndDelimiter, "}}")
    }
    
    func testDefaultConfigurationTagDelimiters() {
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        let template = Template(string: "<%subject%>")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesDefaultConfigurationDelimiters() {
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        let template = Template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationTagDelimiters() {
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = TemplateRepository()
        XCTAssertEqual(repository.configuration.tagStartDelimiter, "<%")
        XCTAssertEqual(repository.configuration.tagEndDelimiter, "%>")

        DefaultConfiguration.tagStartDelimiter = "[["
        DefaultConfiguration.tagEndDelimiter = "]]"
        XCTAssertEqual(repository.configuration.tagStartDelimiter, "<%")
        XCTAssertEqual(repository.configuration.tagEndDelimiter, "%>")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.tagStartDelimiter = "<%"
        configuration.tagEndDelimiter = "%>"
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "<%subject%>")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%subject%>")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        var configuration = Configuration()
        configuration.tagStartDelimiter = "[["
        configuration.tagEndDelimiter = "]]"
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "[[subject]]")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.tagStartDelimiter = "<%"
        DefaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "[["
        repository.configuration.tagEndDelimiter = "]]"
        
        let template = repository.template(string: "[[subject]]")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.tagStartDelimiter = "<%"
        configuration.tagEndDelimiter = "%>"
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Box(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
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
