//
//  InspectFunctionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

// TODO: rename test
class InspectFunctionTests: XCTestCase {
    
    func testBoxedInspectFunction1() {
        class T: MustacheBoxable {
            func mustacheBox() -> Box {
                let inspect = { (key: String) -> Box? in
                    if key == "self" {
                        return Box(self)
                    } else {
                        return Box(key)
                    }
                }
                return Box(inspect)
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
    
    func testBoxedInspectFunction2() {
        class T: MustacheBoxable {
            func mustacheBox() -> Box {
                let inspect = { (key: String) -> Box? in
                    if key == "self" {
                        return Box(self)
                    } else {
                        return Box(key)
                    }
                }
                return Box(
                    value: self,
                    inspect: inspect)
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}