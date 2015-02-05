//
//  InspectFunctionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class InspectFunctionTests: XCTestCase {
    
    func makeInspect() -> InspectFunction {
        return { (key: String) -> Box? in
            if key == "self" {
                return Box(inspect: self.makeInspect())
            } else {
                return boxValue(key)
            }
        }
    }
    
    func testBoxedInspectFunction() {
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(inspect: makeInspect()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}