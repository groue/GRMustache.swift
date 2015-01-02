//
//  MustacheInspectableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 14/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

// TODO: rename test
class MustacheInspectableTests: XCTestCase {
    
    // TODO: make it run
//    func testInspector() {
//        func inspector() -> Inspector {
//            return { (identifier: String) -> Box? in
//                if identifier == "self" {
//                    return Box(inspector())
//                } else {
//                    return Box(identifier)
//                }
//            }
//        }
//        
//        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
//        let rendering = template.render(Box(inspector()))!
//        XCTAssertEqual(rendering, "a,b,c")
//    }
    
    func testBoxedInspector() {
        class T: MustacheBoxable {
            func toBox() -> Box {
                let inspector = { (identifier: String) -> Box? in
                    if identifier == "self" {
                        return Box(self)
                    } else {
                        return Box(identifier)
                    }
                }
                return Box(value: self, inspector: inspector)
            }
        }
        
        let template = Template(string: "{{a}},{{b}},{{#self}}{{c}}{{/self}}")!
        let rendering = template.render(Box(T()))!
        XCTAssertEqual(rendering, "a,b,c")
    }
}