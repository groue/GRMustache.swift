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
        
        // A single protocol that is wrapped in a MustacheCluster
        struct CustomValue1: MustacheInspectable {
            let name: String
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        // Two protocols that are wrapped in a MustacheCluster
        struct CustomValue2: MustacheInspectable, MustacheRenderable {
            let name: String
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return Rendering("")
            }
        }
        
        // A cluster
        struct CustomValue3: MustacheCluster {
            let name: String
            let mustacheBool = true
            var mustacheInspectable: MustacheInspectable? = nil
            let mustacheFilter: MustacheFilter? = nil
            let mustacheTagObserver: MustacheTagObserver? = nil
            let mustacheRenderable: MustacheRenderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        // A cluster that wraps itself
        struct CustomValue4: MustacheCluster, MustacheInspectable {
            let name: String
            let mustacheBool = true
            var mustacheInspectable: MustacheInspectable? { return self }
            let mustacheFilter: MustacheFilter? = nil
            let mustacheTagObserver: MustacheTagObserver? = nil
            let mustacheRenderable: MustacheRenderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        let custom1 = CustomValue1(name: "custom1")
        let custom2 = CustomValue2(name: "custom2")
        let custom3 = CustomValue3(name: "custom3")
        let custom4 = CustomValue4(name: "custom4")
        let custom5 = NSDate()
        
        let value1: Box = Box(custom1)
        let value2: Box = Box(custom2)
        let value3: Box = Box(custom3)
        let value4: Box = Box(custom4)
        let value5: Box = Box(custom5)
        
        let extractedCustom1: CustomValue1 = value1.value()!
        let extractedCustom2: CustomValue2 = value2.value()!
        let extractedCustom3: CustomValue3 = value3.value()!
        let extractedCustom4: CustomValue4 = value4.value()!
        let extractedCustom5: NSDate = value5.value()!
        
        XCTAssertEqual(extractedCustom1.name, "custom1")
        XCTAssertEqual(extractedCustom2.name, "custom2")
        XCTAssertEqual(extractedCustom3.name, "custom3")
        XCTAssertEqual(extractedCustom4.name, "custom4")
        XCTAssertEqual(extractedCustom5, custom5)
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        // A single protocol that is wrapped in a MustacheCluster
        struct CustomValue1: MustacheInspectable {
            let name: String
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        // Two protocols that are wrapped in a MustacheCluster
        struct CustomValue2: MustacheInspectable, MustacheRenderable {
            let name: String
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return Rendering("")
            }
        }
        
        // A cluster
        struct CustomValue3: MustacheCluster {
            let name: String
            let mustacheBool = true
            var mustacheInspectable: MustacheInspectable? = nil
            let mustacheFilter: MustacheFilter? = nil
            let mustacheTagObserver: MustacheTagObserver? = nil
            let mustacheRenderable: MustacheRenderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        // A cluster that wraps itself
        struct CustomValue4: MustacheCluster, MustacheInspectable {
            let name: String
            let mustacheBool = true
            var mustacheInspectable: MustacheInspectable? { return self }
            let mustacheFilter: MustacheFilter? = nil
            let mustacheTagObserver: MustacheTagObserver? = nil
            let mustacheRenderable: MustacheRenderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheKey(key: String) -> Box? {
                return Box()
            }
        }
        
        let filter1 = { (value: CustomValue1?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter2 = { (value: CustomValue2?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter3 = { (value: CustomValue3?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter4 = { (value: CustomValue4?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box(value.name)
            } else {
                return Box("other")
            }
        }
        
        let filter5 = { (value: NSDate?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return Box("custom5")
            } else {
                return Box("other")
            }
        }
        
        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
        
        let value1 = Box([
            "string": Box("success"),
            "custom": Box(CustomValue1(name: "custom1")),
            "f": BoxedFilter(filter1)
            ])
        let rendering1 = template.render(value1)!
        XCTAssertEqual(rendering1, "custom1,other")
        
        let value2 = Box([
            "string": Box("success"),
            "custom": Box(CustomValue2(name: "custom2")),
            "f": BoxedFilter(filter2)])
        let rendering2 = template.render(value2)!
        XCTAssertEqual(rendering2, "custom2,other")
        
        let value3 = Box([
            "string": Box("success"),
            "custom": Box(CustomValue3(name: "custom3")),
            "f": BoxedFilter(filter3)
            ])
        let rendering3 = template.render(value3)!
        XCTAssertEqual(rendering3, "custom3,other")
        
        let value4 = Box([
            "string": Box("success"),
            "custom": Box(CustomValue4(name: "custom4")),
            "f": BoxedFilter(filter4)])
        let rendering4 = template.render(value4)!
        XCTAssertEqual(rendering4, "custom4,other")
        
        let value5 = Box([
            "string": Box("success"),
            "custom": Box(NSDate()),
            "f": BoxedFilter(filter5)])
        let rendering5 = template.render(value5)!
        XCTAssertEqual(rendering5, "custom5,other")
    }

}
