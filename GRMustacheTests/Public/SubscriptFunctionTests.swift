//
//  SubscriptFunctionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class SubscriptFunctionTests: XCTestCase {
    
    func makeSubscriptFunction() -> SubscriptFunction {
        return { (key: String) -> MustacheBox? in
            if key == "self" {
                return Box(self.makeSubscriptFunction())
            } else {
                return Box(key)
            }
        }
    }
    
    func testBoxedSubscriptFunction() {
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(makeSubscriptFunction()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}