//
//  GRMustacheSuiteTest.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation
import XCTest

class GRMustacheSuiteTests: XCTestCase {
    
    func testSuite() {
        runTestsFromResource("comments.json", directory: "GRMustacheSuite")
        runTestsFromResource("compound_keys.json", directory: "GRMustacheSuite")
        runTestsFromResource("delimiters.json", directory: "GRMustacheSuite")
        runTestsFromResource("expression_parsing_errors.json", directory: "GRMustacheSuite")
        runTestsFromResource("filters.json", directory: "GRMustacheSuite")
        runTestsFromResource("general.json", directory: "GRMustacheSuite")
        runTestsFromResource("implicit_iterator.json", directory: "GRMustacheSuite")
        runTestsFromResource("inheritable_partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("inheritable_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("inverted_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("pragmas.json", directory: "GRMustacheSuite")
        runTestsFromResource("sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("standard_library.json", directory: "GRMustacheSuite")
        runTestsFromResource("tag_parsing_errors.json", directory: "GRMustacheSuite")
        runTestsFromResource("text_rendering.json", directory: "GRMustacheSuite")
        runTestsFromResource("variables.json", directory: "GRMustacheSuite")
    }
    
    func runTestsFromResource(name: String, directory: String) {
        let testBundle = NSBundle(forClass: GRMustacheSuiteTests.self)
        let path: String! = testBundle.pathForResource(directory, ofType:nil)?.stringByAppendingPathComponent(name)
        if path == nil {
            XCTFail("No such test suite \(directory)/\(name)")
            return
        }
        
        let data: NSData! = NSData(contentsOfFile:path)
        if data == nil {
            XCTFail("No test suite in \(path)")
            return
        }
        
        var error: NSError?
        let testSuite = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &error) as NSDictionary!
        if testSuite == nil {
            XCTFail("\(error)")
            return
        }
        
        let tests = testSuite["tests"] as NSArray!
        if tests == nil {
            XCTFail("Missing tests in \(path)")
            return
        }
        
        for test in tests {
            let testName = test["name"] as String!
            
            var templateRepository: TemplateRepository!
            if let partials = test["partials"] as? NSDictionary {
                templateRepository = TemplateRepository(templates: partials as [String: String])
            } else {
                templateRepository = TemplateRepository()
            }
            
            let templateString = test["template"] as String
            if let template = templateRepository.templateFromString(templateString, error: &error) {
                let data = test["data"]
                if let rendering = template.render(MustacheValue.ObjCValue(data), error: &error) {
                    if let expectedRendering = test["expected"] as String! {
                        XCTAssertEqual(rendering, expectedRendering, "Unexpected rendering of test \(testName) from \(path)")
                    } else {
                        XCTFail("Not implemented")
                    }
                } else {
                    XCTFail("Error rendering test \(testName) from \(path): \(error!)")
                }
            } else {
                XCTFail("Error loading test \(testName) from \(path): \(error!)")
            }
        }
    }
}