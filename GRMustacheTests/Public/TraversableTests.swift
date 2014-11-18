//
//  TraversableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TraversableTests: XCTestCase {
 
    func testTraversable() {
        class T: MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                if identifier == "self" {
                    return Value(self)
                } else {
                    return Value(identifier)
                }
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Value(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}