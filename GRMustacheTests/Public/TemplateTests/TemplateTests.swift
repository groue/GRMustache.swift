//
//  TemplateTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateTests: XCTestCase {
    
    func testTemplatebelongsToItsOriginTemplateRepository() {
        let repo = TemplateRepository()
        let template = repo.template(string:"")!
        XCTAssertTrue(template.repository === repo)
    }
    
    func testTemplateExtendBaseContextWithValue() {
        let template = Template(string: "{{name}}")!
        template.extendBaseContext(value: Value(["name": "Arthur"]))
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "Arthur")
        
        rendering = template.render(Value(["name": "Bobby"]))!
        XCTAssertEqual(rendering, "Bobby")
    }
    
    func testTemplateExtendBaseContextWithProtectedValue() {
        // TODO: import test from GRMustache
    }
    
    func testTemplateExtendBaseContextWithTagObserver() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                return Value("observer")
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue value: Value) {
            }
        }

        let template = Template(string: "{{name}}")!
        template.extendBaseContext(tagObserver: TestedTagObserver())
        let rendering = template.render()!
        XCTAssertEqual(rendering, "observer")
    }
}
