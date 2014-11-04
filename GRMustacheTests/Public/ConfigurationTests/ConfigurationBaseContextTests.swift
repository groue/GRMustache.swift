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
        
        Configuration.defaultConfiguration.baseContext = Configuration().baseContext
    }
    
    func testFactoryConfigurationHasStandardLibraryInBaseContextRegardlessOfDefaultConfiguration() {
        Configuration.defaultConfiguration.baseContext = Context()
        let repository = MustacheTemplateRepository()
        repository.configuration = Configuration()
        let template = repository.templateFromString("{{uppercase(foo)}}", error: nil)!
        let rendering = template.render(MustacheValue(["foo": MustacheValue("success")]), error: nil)!
        XCTAssertEqual(rendering, "SUCCESS")
    }
    
    func testDefaultConfigurationCustomBaseContext() {
        Configuration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": MustacheValue("success")]))
        let template = MustacheTemplate(string: "{{foo}}", error: nil)!
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultConfigurationCustomBaseContextHasNoStandardLibrary() {
        Configuration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": MustacheValue("success")]))
        let template = MustacheTemplate(string: "{{uppercase(foo)}}", error: nil)!
        var error: NSError?
        let rendering = template.render(MustacheValue(), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError); // no such filter
    }
    
    func testTemplateBaseContextOverridesDefaultConfigurationBaseContext() {
        Configuration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": MustacheValue("failure")]))
        let template = MustacheTemplate(string: "{{foo}}", error: nil)!
        template.baseContext = Context(MustacheValue(["foo": MustacheValue("success")]))
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext() {
        Configuration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": MustacheValue("success")]))
        let repository = MustacheTemplateRepository()
        let template = repository.templateFromString("{{foo}}", error: nil)!
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
}