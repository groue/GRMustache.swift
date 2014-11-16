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
        let rendering = Template(string:"Hello {{name}}!")!.render(Value(user))!
        XCTAssertEqual(rendering, "Hello Arthur!")
    }
    
    func testCustomValueExtraction() {
        // Test that one can extract a custom value from Value.

        // A single protocol that is wrapped in a Cluster
        struct CustomValue1: Traversable {
            let name: String
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        // Two protocols that are wrapped in a Cluster
        struct CustomValue2: Traversable, Renderable {
            let name: String
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }
        
        // A cluster
        struct CustomValue3: Cluster {
            let name: String
            let mustacheBool = true
            var mustacheTraversable: Traversable? = nil
            let mustacheFilter: Filter? = nil
            let mustacheTagObserver: TagObserver? = nil
            let mustacheRenderable: Renderable? = nil
            
            init(name: String) {
                self.name = name
            }

            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        // A cluster that wraps itself
        struct CustomValue4: Cluster, Traversable {
            let name: String
            let mustacheBool = true
            var mustacheTraversable: Traversable? { return self }
            let mustacheFilter: Filter? = nil
            let mustacheTagObserver: TagObserver? = nil
            let mustacheRenderable: Renderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        let custom1 = CustomValue1(name: "custom1")
        let custom2 = CustomValue2(name: "custom2")
        let custom3 = CustomValue3(name: "custom3")
        let custom4 = CustomValue4(name: "custom4")
        
        let value1: Value = Value(custom1)
        let value2: Value = Value(custom2)
        let value3: Value = Value(custom3)
        let value4: Value = Value(custom4)
        
        let extractedCustom1: CustomValue1 = value1.object()!
        let extractedCustom2: CustomValue2 = value2.object()!
        let extractedCustom3: CustomValue3 = value3.object()!
        let extractedCustom4: CustomValue4 = value4.object()!
        
        XCTAssertEqual(extractedCustom1.name, "custom1")
        XCTAssertEqual(extractedCustom2.name, "custom2")
        XCTAssertEqual(extractedCustom3.name, "custom3")
        XCTAssertEqual(extractedCustom4.name, "custom4")
    }
    
    func testCustomValueFilter() {
        // Test that one can define a filter taking a CustomValue as an argument.
        
        // A single protocol that is wrapped in a Cluster
        struct CustomValue1: Traversable {
            let name: String
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        // Two protocols that are wrapped in a Cluster
        struct CustomValue2: Traversable, Renderable {
            let name: String
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return nil
            }
        }
        
        // A cluster
        struct CustomValue3: Cluster {
            let name: String
            let mustacheBool = true
            var mustacheTraversable: Traversable? = nil
            let mustacheFilter: Filter? = nil
            let mustacheTagObserver: TagObserver? = nil
            let mustacheRenderable: Renderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        // A cluster that wraps itself
        struct CustomValue4: Cluster, Traversable {
            let name: String
            let mustacheBool = true
            var mustacheTraversable: Traversable? { return self }
            let mustacheFilter: Filter? = nil
            let mustacheTagObserver: TagObserver? = nil
            let mustacheRenderable: Renderable? = nil
            
            init(name: String) {
                self.name = name
            }
            
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value()
            }
        }
        
        let filter1 = { (value: CustomValue1?) -> (Value?) in
            if let value = value {
                return Value(value.name)
            } else {
                return Value("other")
            }
        }

        let filter2 = { (value: CustomValue2?) -> (Value?) in
            if let value = value {
                return Value(value.name)
            } else {
                return Value("other")
            }
        }

        let filter3 = { (value: CustomValue3?) -> (Value?) in
            if let value = value {
                return Value(value.name)
            } else {
                return Value("other")
            }
        }
        
        let filter4 = { (value: CustomValue4?) -> (Value?) in
            if let value = value {
                return Value(value.name)
            } else {
                return Value("other")
            }
        }
        
        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
        
        let value1 = Value([
            "string": Value("success"),
            "custom": Value(CustomValue1(name: "custom1")),
            "f": Value(filter1)
            ])
        let rendering1 = template.render(value1)!
        XCTAssertEqual(rendering1, "custom1,other")
        
        let value2 = Value([
            "string": Value("success"),
            "custom": Value(CustomValue2(name: "custom2")),
            "f": Value(filter2)
            ])
        let rendering2 = template.render(value2)!
        XCTAssertEqual(rendering2, "custom2,other")
        
        let value3 = Value([
            "string": Value("success"),
            "custom": Value(CustomValue3(name: "custom3")),
            "f": Value(filter3)
            ])
        let rendering3 = template.render(value3)!
        XCTAssertEqual(rendering3, "custom3,other")
        
        let value4 = Value([
            "string": Value("success"),
            "custom": Value(CustomValue4(name: "custom4")),
            "f": Value(filter4)
            ])
        let rendering4 = template.render(value4)!
        XCTAssertEqual(rendering4, "custom4,other")
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

