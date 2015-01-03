//
//  InspectorTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

// TODO: rename test
class InspectorTests: XCTestCase {
    
    func testBoxedInspector1() {
        class T: MustacheBoxable {
            func mustacheBox() -> Box {
                let inspector = { (key: String) -> Box? in
                    if key == "self" {
                        return Box(self)
                    } else {
                        return Box(key)
                    }
                }
                return Box(inspector)
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
    
    func testBoxedInspector2() {
        class T: MustacheBoxable {
            func mustacheBox() -> Box {
                let inspector = { (key: String) -> Box? in
                    if key == "self" {
                        return Box(self)
                    } else {
                        return Box(key)
                    }
                }
                return Box(
                    value: self,
                    inspector: inspector)
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}