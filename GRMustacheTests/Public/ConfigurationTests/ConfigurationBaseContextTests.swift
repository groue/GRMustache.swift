//
//  ConfigurationBaseContextTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class ConfigurationBaseContextTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        MustacheConfiguration.defaultConfiguration.baseContext = MustacheConfiguration().baseContext
    }
    
    func testFactoryConfigurationHasStandardLibraryInBaseContextRegardlessOfDefaultConfiguration() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context()
        
        let repository = MustacheTemplateRepository()
        repository.configuration = MustacheConfiguration()
        
        let template = repository.template(string: "{{uppercase(foo)}}")!
        let rendering = template.render(MustacheValue(["foo": "success"]))!
        XCTAssertEqual(rendering, "SUCCESS")
    }
    
    func testDefaultConfigurationCustomBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let template = MustacheTemplate(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultConfigurationCustomBaseContextHasNoStandardLibrary() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let template = MustacheTemplate(string: "{{uppercase(foo)}}")!
        var error: NSError?
        let rendering = template.render(MustacheValue(), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError); // no such filter
    }
    
    func testTemplateBaseContextOverridesDefaultConfigurationBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "failure"]))
        
        let template = MustacheTemplate(string: "{{foo}}")!
        template.baseContext = Context(MustacheValue(["foo": "success"]))
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let repository = MustacheTemplateRepository()
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = MustacheConfiguration()
        configuration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = MustacheTemplateRepository()
        repository.configuration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "failure"]))
        
        var configuration = MustacheConfiguration()
        configuration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "failure"]))
        
        let repository = MustacheTemplateRepository()
        repository.configuration.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let template = repository.template(string: "{{foo}}")!
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenSettingTheWholeConfiguration() {
        var configuration = MustacheConfiguration()
        configuration.baseContext = Context(MustacheValue(["foo": "failure"]))
        
        let repository = MustacheTemplateRepository()
        repository.configuration = configuration
        
        let template = repository.template(string: "{{foo}}")!
        template.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let rendering = template.render(MustacheValue())!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateBaseContextOverridesRepositoryConfigurationBaseContextWhenUpdatingRepositoryConfiguration() {
        let repository = MustacheTemplateRepository()
        repository.configuration.baseContext = Context(MustacheValue(["foo": "failure"]))
        
        let template = repository.template(string: "{{foo}}")!
        template.baseContext = Context(MustacheValue(["foo": "success"]))
        
        let rendering = template.render(MustacheValue())!
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