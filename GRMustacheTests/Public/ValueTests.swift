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
        
        struct BoxableStruct {
            let name: String
            func mustacheBox() -> Box {
                return Box(value: self)
            }
        }
        
        struct Struct {
            let name: String
        }
        
        class BoxableClass {
            let name: String
            init(name: String) {
                self.name = name
            }
            func mustacheBox() -> Box {
                return Box(value: self)
            }
        }
        
        class Class {
            let name: String
            init(name: String) {
                self.name = name
            }
        }
        
        let boxableStruct = BoxableStruct(name: "BoxableStruct")
        let boxableClass = BoxableClass(name: "BoxableClass")
        let optionalBoxableClass: BoxableClass? = BoxableClass(name: "BoxableClass")
        let NSObject = NSDate()
        
        let boxedBoxableStruct = boxableStruct.mustacheBox()
        let boxedStruct = Box(value: Struct(name: "Struct"))
        let boxedBoxableClass = boxableClass.mustacheBox()
        let boxedOptionalBoxableClass = optionalBoxableClass!.mustacheBox()
        let boxedClass = Box(value: Class(name: "Class"))
        let boxedNSObject = boxValue(NSObject)
        
        let extractedBoxableStruct = boxedBoxableStruct.value as BoxableStruct
        let extractedStruct = boxedStruct.value as Struct
        let extractedBoxableClass = boxedBoxableClass.value as BoxableClass
        let extractedOptionalBoxableClass = boxedOptionalBoxableClass.value as? BoxableClass
        let extractedClass = boxedClass.value as Class
        let extractedNSObject = boxedNSObject.value as NSDate
        
        XCTAssertEqual(extractedBoxableStruct.name, "BoxableStruct")
        XCTAssertEqual(extractedStruct.name, "Struct")
        XCTAssertEqual(extractedBoxableClass.name, "BoxableClass")
        XCTAssertEqual(extractedOptionalBoxableClass!.name, "BoxableClass")
        XCTAssertEqual(extractedClass.name, "Class")
        XCTAssertEqual(extractedNSObject, NSObject)
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        struct Boxable: MustacheBoxable {
            let name: String
            var mustacheBox: Box {
                return Box(value: self)
            }
        }
        
        let filter1 = { (value: Boxable?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return boxValue(value.name)
            } else {
                return boxValue("other")
            }
        }
        
        let filter2 = { (value: Boxable?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return boxValue(value.name)
            } else {
                return boxValue("other")
            }
        }
        
        let filter3 = { (value: NSDate?, error: NSErrorPointer) -> Box? in
            if let value = value {
                return boxValue("custom3")
            } else {
                return boxValue("other")
            }
        }
        
        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
        
        let value1 = boxValue([
            "string": boxValue("success"),
            "custom": boxValue(Boxable(name: "custom1")),
            "f": Box(filter: Filter(filter1))
            ])
        let rendering1 = template.render(value1)!
        XCTAssertEqual(rendering1, "custom1,other")
        
        let value2 = boxValue([
            "string": boxValue("success"),
            "custom": Box(value: Boxable(name: "custom2")),
            "f": Box(filter: Filter(filter2))])
        let rendering2 = template.render(value2)!
        XCTAssertEqual(rendering2, "custom2,other")
        
        let value3 = boxValue([
            "string": boxValue("success"),
            "custom": boxValue(NSDate()),
            "f": Box(filter: Filter(filter3))])
        let rendering3 = template.render(value3)!
        XCTAssertEqual(rendering3, "custom3,other")
    }

}
