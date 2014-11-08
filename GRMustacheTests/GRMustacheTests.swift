//
//  GRMustacheTests.swift
//  GRMustacheTests
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation
import XCTest

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
        let repository = MustacheTemplateRepository()
        if let template = repository.template(string: "<{{name}}>", error: &error) {
            let data = MustacheValue(["name": "Arthur"])
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
        let repository = MustacheTemplateRepository()
        if let template = repository.template(string: "<{{name}}>", error: &error) {
            let data = MustacheValue(["name": "Arthur"])
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
        let repository = MustacheTemplateRepository(templates: ["partial": "{{name}}"])
        if let template = repository.template(string: "<{{>partial}}>", error: &error) {
            let data = MustacheValue(["name": "Arthur"])
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
        let template = MustacheTemplate(named: "example1", bundle: testBundle)!
        let value = MustacheValue([
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
        
        let pluralizeFilter = { (count: Int?) -> (MustacheValue) in
            
            // This filter returns an object that performs custom rendering:
            
            return MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
                
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
        
        MustacheConfiguration.defaultConfiguration.extendBaseContextWithValue(MustacheValue(pluralizeFilter), forKey: "pluralize")
        
        
        // I have 3 cats.
        
        let testBundle = NSBundle(forClass: GRMustacheTests.self)
        let template = MustacheTemplate(named: "example2", bundle: testBundle)!
        let value = MustacheValue(["cats": ["Kitty", "Pussy", "Melba"]])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "I have 3 cats.")
    }
    
    func testReadmeExample3() {
        let user = ReadmeExample3User(name: "Arthur")
        let rendering = MustacheTemplate.render(MustacheValue(user), fromString:"Hello {{name}}!")!
        XCTAssertEqual(rendering, "Hello Arthur!")
    }
    
    func testCustomValueExtraction() {
        // Test that one can define a value from MustacheValue.

        struct CustomValue: MustacheTraversable, MustacheRenderable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue()
            }
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }

        let value = MustacheValue([
            "string": MustacheValue("success"),
            "custom": MustacheValue(CustomValue()),
            "f": MustacheValue({ (value: MustacheValue, error: NSErrorPointer?) -> (MustacheValue?) in
                if let c: CustomValue = value.object() {
                    return MustacheValue("custom")
                } else {
                    return MustacheValue("other")
                }
            })
            ])
        let template = MustacheTemplate(string:"{{f(custom)}},{{f(string)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "custom,other")
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        struct CustomValue: MustacheTraversable, MustacheRenderable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue()
            }
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }
        
        let filterBlock = { (value: CustomValue?) -> (MustacheValue?) in
            if value != nil {
                return MustacheValue("custom")
            } else {
                return MustacheValue("other")
            }
        }
        let filterValue = MustacheValue(filterBlock)
        let value = MustacheValue([
            "string": MustacheValue("success"),
            "custom": MustacheValue(CustomValue()),
            "f": filterValue
            ])
        let template = MustacheTemplate(string:"{{f(custom)}},{{f(string)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "custom,other")
    }
}

struct ReadmeExample3User {
    let name: String
}

extension ReadmeExample3User: MustacheTraversable {
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        switch identifier {
        case "name":
            return MustacheValue(name)
        default:
            return nil
        }
    }
}

