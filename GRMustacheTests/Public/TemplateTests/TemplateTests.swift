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
    
    func testTemplateBelongsToItsOriginTemplateRepository() {
        let repo = TemplateRepository()
        let template = repo.template(string:"")!
        XCTAssertTrue(template.repository === repo)
    }
    
    func testTemplateExtendBaseContextWithValue() {
        let template = Template(string: "{{name}}")!
        template.registerInBaseContext("name", Box("Arthur"))
        
        var rendering = template.render()!
        XCTAssertEqual(rendering, "Arthur")
        
        rendering = template.render(Box(["name": "Bobby"]))!
        XCTAssertEqual(rendering, "Bobby")
    }
    
    func testTemplateExtendBaseContextWithProtectedValue() {
        // TODO: import test from GRMustache
    }
    
    func testTemplateExtendBaseContextWithWillRenderFunction() {
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            return Box("observer")
        }
        
        let template = Template(string: "{{name}}")!
        template.extendBaseContext(Box(willRender))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "observer")
    }
}
