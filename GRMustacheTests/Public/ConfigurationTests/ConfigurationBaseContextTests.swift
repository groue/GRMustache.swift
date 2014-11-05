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
        let template = repository.template(string: "{{uppercase(foo)}}", error: nil)!
        let rendering = template.render(MustacheValue(["foo": "success"]), error: nil)!
        XCTAssertEqual(rendering, "SUCCESS")
    }
    
    func testDefaultConfigurationCustomBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        let template = MustacheTemplate(string: "{{foo}}", error: nil)!
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultConfigurationCustomBaseContextHasNoStandardLibrary() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        let template = MustacheTemplate(string: "{{uppercase(foo)}}", error: nil)!
        var error: NSError?
        let rendering = template.render(MustacheValue(), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError); // no such filter
    }
    
    func testTemplateBaseContextOverridesDefaultConfigurationBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "failure"]))
        let template = MustacheTemplate(string: "{{foo}}", error: nil)!
        template.baseContext = Context(MustacheValue(["foo": "success"]))
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
    
    func testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext() {
        MustacheConfiguration.defaultConfiguration.baseContext = Context(MustacheValue(["foo": "success"]))
        let repository = MustacheTemplateRepository()
        let template = repository.template(string: "{{foo}}", error: nil)!
        let rendering = template.render(MustacheValue(), error: nil)!
        XCTAssertEqual(rendering, "success")
    }
}