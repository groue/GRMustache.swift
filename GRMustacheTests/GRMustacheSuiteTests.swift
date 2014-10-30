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
        runTestsFromResource("inheritable_partials.json", directory: "GRMustacheSuite")
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
        
        for testDictionary in tests {
            let test = Test(path: path, dictionary: testDictionary as NSDictionary)
            test.run()
        }
    }
    
    class Test {
        let path: String
        let dictionary: NSDictionary
        
        init(path: String, dictionary: NSDictionary) {
            self.path = path
            self.dictionary = dictionary
        }
        
        func run() {
            for template in templates {
                testRendering(template)
            }
        }
        
        //
        
        var description: String { return "test `\(name)` at \(path)" }
        var name: String { return dictionary["name"] as String }
        var partialsDictionary: NSDictionary? { return dictionary["partials"] as NSDictionary? }
        var templateString: String? { return dictionary["template"] as String? }
        var templateName: String? { return dictionary["template_name"] as String? }
        var renderedValue: MustacheValue { return MustacheValue.ObjCValue(dictionary["data"]!).canonical() }
        var expectedRendering: String? { return dictionary["expected_rendering"] as String? }
        var expectedError: String? { return dictionary["expected_error"] as String? }
        
        var templateRepositories: [TemplateRepository] {
            if let partialsDictionary = partialsDictionary {
                return [TemplateRepository(templates: partialsDictionary as [String: String])]
            } else {
                return [TemplateRepository()]
            }
        }
        
        var templates: [Template] {
            if let templateString = templateString {
                var templates: [Template] = []
                for templateRepository in templateRepositories {
                    var error: NSError?
                    if let template = templateRepository.templateFromString(templateString, error: &error) {
                        templates.append(template)
                    } else {
                        testError(error!)
                    }
                }
                return templates
            }/* else if let templateName = templateName {
                var templates: [Template] = []
                for templateRepository in templateRepositories {
                    var error: NSError?
                    if let template = templateRepository.templateNamed(templateName, error: &error) {
                        templates.append(template)
                    } else {
                        testError(error!)
                    }
                }
                return templates
            }*/ else {
                XCTFail("Missing `template` and `template_name` in \(description)")
                return []
            }
        }
        
        func testRendering(template: Template) {
            var error: NSError?
            if let rendering = template.render(renderedValue, error: &error) {
                if let expectedRendering = expectedRendering as String! {
                    if expectedRendering != rendering {
                        XCTAssertEqual(rendering, expectedRendering, "Unexpected rendering of \(description)")
                    }
                }
                testSuccess()
            } else {
                testError(error)
            }
        }
        
        func testError(error: NSError!) {
            if let expectedError = expectedError {
                var regError: NSError?
                if let reg = NSRegularExpression(pattern: expectedError, options: NSRegularExpressionOptions(0), error: &regError) {
                    let errorMessage = error.localizedDescription
                    let matches = reg.matchesInString(errorMessage, options: NSMatchingOptions(0), range:NSMakeRange(0, countElements(errorMessage)))
                    if countElements(matches) == 0 {
                        XCTFail("`\(errorMessage)` does not match /\(expectedError)/ in \(description)")
                    }
                } else {
                    XCTFail("Invalid expected_error in \(description): \(regError!)")
                }
            } else {
                XCTFail("Unexpected error in \(description): \(error)")
            }
        }
        
        func testSuccess() {
            if expectedError != nil {
                XCTFail("Unexpected success in \(description)")
            }
        }
        
        deinit {
            
        }
    }
}