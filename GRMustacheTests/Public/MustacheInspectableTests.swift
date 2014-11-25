//
//  MustacheInspectableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class MustacheInspectableTests: XCTestCase {
 
    func testInspectable() {
        class T: MustacheInspectable {
            func valueForMustacheKey(key: String) -> Value? {
                if key == "self" {
                    return Value(self)
                } else {
                    return Value(key)
                }
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Value(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}