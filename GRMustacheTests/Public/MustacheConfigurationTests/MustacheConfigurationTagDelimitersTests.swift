//
//  ConfigurationTagDelimitersTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 05/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ConfigurationTagDelimitersTests: XCTestCase {
   
    override func tearDown() {
        super.tearDown()
        
        Configuration.defaultConfiguration.tagStartDelimiter = "{{"
        Configuration.defaultConfiguration.tagEndDelimiter = "}}"
    }
    
    func testFactoryConfigurationHasTagDelimitersRegardlessOfDefaultConfiguration() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let configuration = Configuration()
        XCTAssertEqual(configuration.tagStartDelimiter, "{{")
        XCTAssertEqual(configuration.tagEndDelimiter, "}}")
    }
    
    func testDefaultConfigurationTagDelimiters() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let template = Template(string: "<%subject%>")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesDefaultConfigurationDelimiters() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let template = Template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationTagDelimiters() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = TemplateRepository()
        XCTAssertEqual(repository.configuration.tagStartDelimiter, "<%")
        XCTAssertEqual(repository.configuration.tagEndDelimiter, "%>")

        Configuration.defaultConfiguration.tagStartDelimiter = "[["
        Configuration.defaultConfiguration.tagEndDelimiter = "]]"
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
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%subject%>")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        var configuration = Configuration()
        configuration.tagStartDelimiter = "[["
        configuration.tagEndDelimiter = "]]"
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "[[subject]]")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        Configuration.defaultConfiguration.tagStartDelimiter = "<%"
        Configuration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "[["
        repository.configuration.tagEndDelimiter = "]]"
        
        let template = repository.template(string: "[[subject]]")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.tagStartDelimiter = "<%"
        configuration.tagEndDelimiter = "%>"
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Value(["subject": "---"]))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]")!
        let rendering = template.render(Value(["subject": "---"]))!
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
