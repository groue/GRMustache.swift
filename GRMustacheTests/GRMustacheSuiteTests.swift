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
//        runTestsFromResource("filters.json", directory: "GRMustacheSuite")
        runTestsFromResource("general.json", directory: "GRMustacheSuite")
        runTestsFromResource("implicit_iterator.json", directory: "GRMustacheSuite")
//        runTestsFromResource("inheritable_partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("inheritable_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("inverted_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("pragmas.json", directory: "GRMustacheSuite")
        runTestsFromResource("sections.json", directory: "GRMustacheSuite")
//        runTestsFromResource("standard_library.json", directory: "GRMustacheSuite")
        runTestsFromResource("tag_parsing_errors.json", directory: "GRMustacheSuite")
//        runTestsFromResource("text_rendering.json", directory: "GRMustacheSuite")
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
                var templates: [String: String] = [:]
                partials.enumerateKeysAndObjectsUsingBlock({ (key, value, _) -> Void in
                    if let key = key as? String {
                        if let value = value as? String {
                            templates[key] = value
                        }
                    }
                })
                templateRepository = TemplateRepository(templates: templates)
            } else {
                templateRepository = TemplateRepository()
            }
            
            if let templateString = test["template"] as? String {
                if let template = templateRepository.templateFromString(templateString, error: &error) {
                    if let data: AnyObject = test["data"] {
                        let value = MustacheValue.ObjCValue(data).canonical()
                        if let rendering = template.render(value, error: &error) {
                            if let expectedRendering = test["expected"] as String! {
                                if expectedRendering != rendering {
                                    XCTAssertEqual(rendering, expectedRendering, "Unexpected rendering of test `\(testName)` in \(path)")
                                    template.render(value, error: nil)
                                }
                            } else if let expectedError = test["expected_error"] as? String {
                                XCTFail("Unexpected successful rendering in test `\(testName)` in \(path)")
                            } else {
                                XCTFail("Missing expectation in test `\(testName)` in \(path)")
                            }
                        } else if let expectedError = test["expected_error"] as? String {
                            if let expectedErrorReg = NSRegularExpression(pattern: expectedError, options: NSRegularExpressionOptions(0), error: &error) {
                                let errorMessage = error!.localizedDescription
                                let matches = expectedErrorReg.matchesInString(errorMessage, options: NSMatchingOptions(0), range:NSMakeRange(0, countElements(errorMessage)))
                                if countElements(matches) == 0 {
                                    XCTFail("`\(errorMessage)` does not match /\(expectedError)/ in test `\(testName)` in \(path)")
                                }
                            } else {
                                XCTFail("Could not load expected_error from test `\(testName)` in \(path): \(error!)")
                            }
                        } else {
                            XCTFail("Error rendering test `\(testName)` in \(path): \(error!)")
                        }
                    } else {
                        XCTFail("Missing data in test `\(testName)` in \(path)")
                    }
                } else {
                    if let expectedError = test["expected_error"] as? String {
                        if let expectedErrorReg = NSRegularExpression(pattern: expectedError, options: NSRegularExpressionOptions(0), error: &error) {
                            let errorMessage = error!.localizedDescription
                            let matches = expectedErrorReg.matchesInString(errorMessage, options: NSMatchingOptions(0), range:NSMakeRange(0, countElements(errorMessage)))
                            if countElements(matches) == 0 {
                                XCTFail("`\(errorMessage)` does not match /\(expectedError)/ in test `\(testName)` in \(path)")
                                templateRepository.templateFromString(templateString, error: &error)
                            }
                        } else {
                            XCTFail("Could not load expected_error from test `\(testName)` in \(path): \(error!)")
                        }
                    } else {
                        XCTFail("Error loading template from test `\(testName)` in \(path): \(error!)")
                        templateRepository.templateFromString(templateString, error: &error)
                    }
                }
            } else {
                XCTFail("Missing template in test `\(testName)` in \(path)")
            }
        }
    }
}