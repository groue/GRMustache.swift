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
        configuration.extendBaseContext(box: Box(["name": "Arthur"]))
        let repository = TemplateRepository()
        repository.configuration = configuration
        let template = repository.template(string: "{{name}}")!
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "Arthur")
        
        rendering = template.render(Box(["name": "Bobby"]))!
        XCTAssertEqual(rendering, "Bobby")
    }
    
    func testConfigurationExtendBaseContextWithProtectedObject() {
        // TODO: import test from GRMustache
    }
    
//    func testConfigurationExtendBaseContextWithTagObserver() {
//        class TestedTagObserver: MustacheTagObserver {
//            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
//                return Box("delegate")
//            }
//            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
//            }
//        }
//        var configuration = Configuration()
//        configuration.extendBaseContext(tagObserver: TestedTagObserver())
//        let repository = TemplateRepository()
//        repository.configuration = configuration
//        let template = repository.template(string: "{{name}}")!
//        let rendering = template.render()!
//        XCTAssertEqual(rendering, "delegate")
//    }
}
