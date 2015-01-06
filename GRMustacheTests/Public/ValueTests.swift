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
        
        struct BoxableStruct: MustacheBoxable {
            let name: String
            func mustacheBox() -> Box {
                return Box(value: self)
            }
        }
        
        struct Struct {
            let name: String
        }
        
        class BoxableClass: MustacheBoxable {
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
        let optionalBoxableStruct: BoxableStruct? = BoxableStruct(name: "BoxableStruct")
        let boxableClass = BoxableClass(name: "BoxableClass")
        let optionalBoxableClass: BoxableClass? = BoxableClass(name: "BoxableClass")
        let NSObject = NSDate()
        
        let boxedBoxableStruct: Box = Box(boxableStruct)
//        let boxedOptionalBoxableStruct: Box = Box(optionalBoxableStruct)  // TODO: uncomment and avoid compiler error
        let boxedStruct: Box = Box(value: Struct(name: "Struct"))
        let boxedBoxableClass: Box = Box(boxableClass)
//        let boxedOptionalBoxableClass: Box = Box(optionalBoxableClass)  // TODO: uncomment and avoid runtime error
        let boxedClass: Box = Box(value: Class(name: "Class"))
        let boxedNSObject: Box = Box(NSObject)
        
        let extractedBoxableStruct = boxedBoxableStruct.value as BoxableStruct
//        let extractedOptionalBoxableStruct = boxedOptionalBoxableStruct.value as? BoxableStruct
        let extractedStruct = boxedStruct.value as Struct
        let extractedBoxableClass = boxedBoxableClass.value as BoxableClass
//        let extractedOptionalBoxableClass = boxedOptionalBoxableClass.value as? BoxableClass
        let extractedClass = boxedClass.value as Class
        let extractedNSObject = boxedNSObject.value as NSDate
        
        XCTAssertEqual(extractedBoxableStruct.name, "BoxableStruct")
//        XCTAssertEqual(extractedOptionalBoxableStruct!.name, "BoxableStruct")
        XCTAssertEqual(extractedStruct.name, "Struct")
        XCTAssertEqual(extractedBoxableClass.name, "BoxableClass")
//        XCTAssertEqual(extractedOptionalBoxableClass!.name, "BoxableClass")
        XCTAssertEqual(extractedClass.name, "Class")
        XCTAssertEqual(extractedNSObject, NSObject)
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
