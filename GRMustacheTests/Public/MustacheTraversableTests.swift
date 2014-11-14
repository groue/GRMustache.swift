//
//  MustacheTraversableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class MustacheTraversableTests: XCTestCase {
 
    func testMustacheTraversable() {
        class T: MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                if identifier == "self" {
                    return MustacheValue(self)
                } else {
                    return MustacheValue(identifier)
                }
            }
        }
        
        let template = MustacheTemplate(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(MustacheValue(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}