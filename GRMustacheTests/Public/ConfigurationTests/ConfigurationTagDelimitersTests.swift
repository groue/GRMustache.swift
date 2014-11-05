//
//  ConfigurationTagDelimitersTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 05/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class ConfigurationTagDelimitersTests: XCTestCase {
   
    override func tearDown() {
        super.tearDown()
        
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "{{"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "}}"
    }
    
    func testFactoryConfigurationHasMustacheTagDelimitersRegardlessOfDefaultConfiguration() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let configuration = MustacheConfiguration()
        XCTAssertEqual(configuration.tagStartDelimiter, "{{")
        XCTAssertEqual(configuration.tagEndDelimiter, "}}")
    }
    
    func testDefaultConfigurationMustacheTagDelimiters() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let template = MustacheTemplate(string: "<%subject%>", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesDefaultConfigurationDelimiters() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let template = MustacheTemplate(string: "<%=[[ ]]=%>[[subject]]", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationTagDelimiters() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = MustacheTemplateRepository()
        XCTAssertEqual(repository.configuration.tagStartDelimiter, "<%")
        XCTAssertEqual(repository.configuration.tagEndDelimiter, "%>")

        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "[["
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "]]"
        XCTAssertEqual(repository.configuration.tagStartDelimiter, "<%")
        XCTAssertEqual(repository.configuration.tagEndDelimiter, "%>")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = MustacheConfiguration()
        configuration.tagStartDelimiter = "<%"
        configuration.tagEndDelimiter = "%>"
        
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "<%subject%>", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = MustacheTemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%subject%>", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        var configuration = MustacheConfiguration()
        configuration.tagStartDelimiter = "[["
        configuration.tagEndDelimiter = "]]"
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "[[subject]]", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        MustacheConfiguration.defaultConfiguration.tagStartDelimiter = "<%"
        MustacheConfiguration.defaultConfiguration.tagEndDelimiter = "%>"
        
        let repository = MustacheTemplateRepository()
        repository.configuration.tagStartDelimiter = "[["
        repository.configuration.tagEndDelimiter = "]]"
        
        let template = repository.template(string: "[[subject]]", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenSettingTheWholeConfiguration() {
        var configuration = MustacheConfiguration()
        configuration.tagStartDelimiter = "<%"
        configuration.tagEndDelimiter = "%>"
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testSetDelimitersTagOverridesRepositoryConfigurationTagDelimitersWhenUpdatingRepositoryConfiguration() {
        let repository = MustacheTemplateRepository()
        repository.configuration.tagStartDelimiter = "<%"
        repository.configuration.tagEndDelimiter = "%>"
        
        let template = repository.template(string: "<%=[[ ]]=%>[[subject]]", error: nil)!
        let rendering = template.render(MustacheValue(["subject": "---"]), error:nil)!
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
