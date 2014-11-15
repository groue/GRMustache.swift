//
//  GRMustacheTests.swift
//  GRMustacheTests
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class GRMustacheTests: XCTestCase {
    
    //    override func setUp() {
    //        super.setUp()
    //        // Put setup code here. This method is called before the invocation of each test method in the class.
    //    }
    //
    //    override func tearDown() {
    //        // Put teardown code here. This method is called after the invocation of each test method in the class.
    //        super.tearDown()
    //    }
    //
    //    func testExample() {
    //        // This is an example of a functional test case.
    //        XCTAssert(true, "Pass")
    //    }
    //
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock() {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
    func testSwiftVariableInterpolation() {
        var error: NSError?
        let repository = TemplateRepository()
        if let template = repository.template(string: "<{{name}}>", error: &error) {
            let data = Value(["name": "Arthur"])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
    
    func testObjCVariableInterpolation() {
        var error: NSError?
        let repository = TemplateRepository()
        if let template = repository.template(string: "<{{name}}>", error: &error) {
            let data = Value(["name": "Arthur"])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
    
    func testPartial() {
        var error: NSError?
        let repository = TemplateRepository(templates: ["partial": "{{name}}"])
        if let template = repository.template(string: "<{{>partial}}>", error: &error) {
            let data = Value(["name": "Arthur"])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
    
    func testReadmeExample1() {
        let testBundle = NSBundle(forClass: GRMustacheTests.self)
        let template = Template(named: "example1", bundle: testBundle)!
        let value = Value([
            "name": "Chris",
            "value": 10000.0,
            "taxed_value": 10000 - (10000 * 0.4),
            "in_ca": true
            ])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "Hello Chris\nYou have just won 10000.0 dollars!\n\nWell, 6000.0 dollars, after taxes.\n")
    }
    
    func testReadmeExample2() {
        // Define the `pluralize` filter.
        //
        // {{# pluralize(count) }}...{{/ }} renders the plural form of the
        // section content if the `count` argument is greater than 1.
        
        let pluralizeFilter = { (count: Int?) -> (Value) in
            
            // This filter returns an object that performs custom rendering:
            
            return Value({ (tag: Tag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
                
                // Fetch the section inner content...
                
                let string = tag.innerTemplateString
                
                // ... and pluralize it if needed.
                
                if count! > 1 {
                    return string + "s"  // naive
                } else {
                    return string
                }
            })
        }
        
        
        // Register the pluralize filter for all Mustache renderings:
        
        Configuration.defaultConfiguration.extendBaseContextWithValue(Value(pluralizeFilter), forKey: "pluralize")
        
        
        // I have 3 cats.
        
        let testBundle = NSBundle(forClass: GRMustacheTests.self)
        let template = Template(named: "example2", bundle: testBundle)!
        let value = Value(["cats": ["Kitty", "Pussy", "Melba"]])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "I have 3 cats.")
    }
    
    func testReadmeExample3() {
        let user = ReadmeExample3User(name: "Arthur")
        let rendering = Template.render(Value(user), fromString:"Hello {{name}}!")!
        XCTAssertEqual(rendering, "Hello Arthur!")
    }
    
    func testCustomValueExtraction() {
        // Test that one can extract a custom value from Value.

        struct CustomValue1: Traversable, Renderable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }
        
        struct CustomValue2: Traversable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        let custom1 = CustomValue1()
        let custom2 = CustomValue2()
        let value1: Value = Value(custom1)
        let value2: Value = Value(custom2)
        
        // The test lies in the fact that those two lines compile:
        let extractedCustom1: CustomValue1? = value1.object()
        let extractedCustom2: CustomValue2? = value2.object()
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        struct CustomValue: Traversable, Renderable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }
        
        let filterValue = Value({ (value: CustomValue?) -> (Value?) in
            if value != nil {
                return Value("custom")
            } else {
                return Value("other")
            }
        })
        let value = Value([
            "string": Value("success"),
            "custom": Value(CustomValue()),
            "f": filterValue
            ])
        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "custom,other")
    }
}

struct ReadmeExample3User {
    let name: String
}

extension ReadmeExample3User: Traversable {
    func valueForMustacheIdentifier(identifier: String) -> Value? {
        switch identifier {
        case "name":
            return Value(name)
        default:
            return nil
        }
    }
}

