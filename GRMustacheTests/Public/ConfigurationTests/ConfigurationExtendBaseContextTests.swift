//
//  ConfigurationExtendBaseContextTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 05/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ConfigurationExtendBaseContextTests: XCTestCase {
   
    func testConfigurationExtendBaseContextWithValue() {
        var configuration = Configuration()
        configuration.extendBaseContext(boxValue(["name": "Arthur"]))
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{name}}")!
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "Arthur")
        
        rendering = template.render(boxValue(["name": "Bobby"]))!
        XCTAssertEqual(rendering, "Bobby")
    }
    
    func testConfigurationExtendBaseContextWithProtectedObject() {
        // TODO: import test from GRMustache
    }
    
    func testConfigurationExtendBaseContextWithWillRenderFunction() {
        let willRender = { (tag: Tag, box: Box) -> Box in
            return boxValue("delegate")
        }
        var configuration = Configuration()
        configuration.extendBaseContext(Box(willRender: willRender))
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{name}}")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "delegate")
    }
}
