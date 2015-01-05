//
//  ValueTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 21/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ValueTests: XCTestCase {
    
    func testCustomValueExtraction() {
        // Test that one can extract a custom value from Box.
        
        struct Boxable: MustacheBoxable {
            let name: String
            func mustacheBox() -> Box {
                return Box(value: self)
            }
        }
        
        let custom1 = Boxable(name: "custom1")
        let custom3 = NSDate()
        
        let value1: Box = Box(custom1)
        let value2: Box = Box(value: Boxable(name: "custom2"))
        let value3: Box = Box(custom3)
        
        let extractedCustom1 = Box(custom1).value as Boxable
        let extractedCustom2 = value2.value as Boxable
        let extractedCustom3 = Box(custom3).value as NSDate
        
        XCTAssertEqual(extractedCustom1.name, "custom1")
        XCTAssertEqual(extractedCustom2.name, "custom2")
        XCTAssertEqual(extractedCustom3, custom3)
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        struct Boxable: MustacheBoxable {
            let name: String
            func mustacheBox() -> Box {
                return Box(value: self)
            }
        }
        
        let filter1 = { (value: Boxable?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter2 = { (value: Boxable?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter3 = { (value: NSDate?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box("custom3")
            } else {
                return Box("other")
            }
        }
        
        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
        
        let value1 = Box([
            "string": Box("success"),
            "custom": Box(Boxable(name: "custom1")),
            "f": Box(Filter(filter1))
            ])
        let rendering1 = template.render(value1)!
        XCTAssertEqual(rendering1, "custom1,other")
        
        let value2 = Box([
            "string": Box("success"),
            "custom": Box(value: Boxable(name: "custom2")),
            "f": Box(Filter(filter2))])
        let rendering2 = template.render(value2)!
        XCTAssertEqual(rendering2, "custom2,other")
        
        let value3 = Box([
            "string": Box("success"),
            "custom": Box(NSDate()),
            "f": Box(Filter(filter3))])
        let rendering3 = template.render(value3)!
        XCTAssertEqual(rendering3, "custom3,other")
    }

}
