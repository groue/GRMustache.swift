//
//  ConfigurationBaseContextTests.swift
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class ConfigurationBaseContextTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        DefaultConfiguration = Configuration()
    }
    
    func testDefaultConfigurationCustomBaseContext() {
        DefaultConfiguration.baseContext = Context(Box(["foo": "success"]))
        
        let template = Template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesDefaultConfigurationBaseContext() {
        DefaultConfiguration.baseContext = Context(Box(["foo": "failure"]))
        
        let template = Template(string: "{{foo}}")!
        template.baseContext = Context(Box(["foo": "success"]))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext() {
        DefaultConfiguration.baseContext = Context(Box(["foo": "success"]))
        
        let repository = TemplateRepository()
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.baseContext = Context(Box(["foo": "success"]))
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(Box(["foo": "success"]))
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        DefaultConfiguration.baseContext = Context(Box(["foo": "failure"]))
        
        var configuration = Configuration()
        configuration.baseContext = Context(Box(["foo": "success"]))
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        DefaultConfiguration.baseContext = Context(Box(["foo": "failure"]))
        
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(Box(["foo": "success"]))
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = Configuration()
        configuration.baseContext = Context(Box(["foo": "failure"]))
        
        let repository = TemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        template.baseContext = Context(Box(["foo": "success"]))
        
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = TemplateRepository()
        repository.configuration.baseContext = Context(Box(["foo": "failure"]))
        
        let template = repository.template(string: "{{foo}}")!
        template.baseContext = Context(Box(["foo": "success"]))
        
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
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