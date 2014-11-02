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
        var partialsDictionary: [String: String]? { return dictionary["partials"] as [String: String]? }
        var templateString: String? { return dictionary["template"] as String? }
        var templateName: String? { return dictionary["template_name"] as String? }
        var renderedValue: MustacheValue { return MustacheValue(dictionary["data"]) }
        var expectedRendering: String? { return dictionary["expected"] as String? }
        var expectedError: String? { return dictionary["expected_error"] as String? }
        
        var templates: [MustacheTemplate] {
            if let partialsDictionary = partialsDictionary {
                if let templateName = templateName {
                    var templates: [MustacheTemplate] = []
                    let templateExtension = templateName.pathExtension
                    for (directoryPath, encoding) in pathsAndEncodingsToPartials(partialsDictionary) {
                        var error: NSError?
                        if let template = MustacheTemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding).templateNamed(templateName.stringByDeletingPathExtension, error: &error) {
                            templates.append(template)
                        } else {
                            XCTAssertNotNil(error, "Expected parsing error in \(description)")
                            testError(error!, replayOnFailure: {
                                let template = MustacheTemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding).templateNamed(templateName.stringByDeletingPathExtension, error: &error)
                            })
                        }
                        if let template = MustacheTemplateRepository(baseURL: NSURL.fileURLWithPath(directoryPath)!, templateExtension: templateExtension, encoding: encoding).templateNamed(templateName.stringByDeletingPathExtension, error: &error) {
                            templates.append(template)
                        } else {
                            XCTAssertNotNil(error, "Expected parsing error in \(description)")
                            testError(error!, replayOnFailure: {
                                let template = MustacheTemplateRepository(baseURL: NSURL.fileURLWithPath(directoryPath)!, templateExtension: templateExtension, encoding: encoding).templateNamed(templateName.stringByDeletingPathExtension, error: &error)
                            })
                        }
                    }
                    return templates
                } else if let templateString = templateString {
                    var templates: [MustacheTemplate] = []
                    for (directoryPath, encoding) in pathsAndEncodingsToPartials(partialsDictionary) {
                        var error: NSError?
                        if let template = MustacheTemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: encoding).templateFromString(templateString, error: &error) {
                            templates.append(template)
                        } else {
                            XCTAssertNotNil(error, "Expected parsing error in \(description)")
                            testError(error!, replayOnFailure: {
                                let template = MustacheTemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: encoding).templateFromString(templateString, error: &error)
                            })
                        }
                        if let template = MustacheTemplateRepository(baseURL: NSURL.fileURLWithPath(directoryPath)!, templateExtension: "", encoding: encoding).templateFromString(templateString, error: &error) {
                            templates.append(template)
                        } else {
                            XCTAssertNotNil(error, "Expected parsing error in \(description)")
                            testError(error!, replayOnFailure: {
                                let template = MustacheTemplateRepository(baseURL: NSURL.fileURLWithPath(directoryPath)!, templateExtension: "", encoding: encoding).templateFromString(templateString, error: &error)
                            })
                        }
                    }
                    return templates
                } else {
                    XCTFail("Missing `template` and `template_name` in \(description)")
                    return []
                }
            } else {
                if let templateName = templateName {
                    XCTFail("Missing `partials` in \(description)")
                    return []
                } else if let templateString = templateString {
                    var error: NSError?
                    if let template = MustacheTemplateRepository().templateFromString(templateString, error: &error) {
                        return [template]
                    } else {
                        XCTAssertNotNil(error, "Expected parsing error in \(description)")
                        testError(error!, replayOnFailure: {
                            let template = MustacheTemplateRepository().templateFromString(templateString, error: &error)
                        })
                        return []
                    }
                } else {
                    XCTFail("Missing `template` and `template_name` in \(description)")
                    return []
                }
            }
        }
        
        func testRendering(template: MustacheTemplate) {
            var error: NSError?
            if let rendering = template.render(renderedValue, error: &error) {
                if let expectedRendering = expectedRendering as String! {
                    if expectedRendering != rendering {
                        XCTAssertEqual(rendering, expectedRendering, "Unexpected rendering of \(description)")
                    }
                }
                testSuccess(replayOnFailure: {
                    let rendering = template.render(self.renderedValue, error: &error)
                })
            } else {
                XCTAssertNotNil(error, "Expected rendering error in \(description)")
                testError(error!, replayOnFailure: {
                    let rendering = template.render(self.renderedValue, error: &error)
                })
            }
        }
        
        func testError(error: NSError, replayOnFailure replayBlock: ()->()) {
            if let expectedError = expectedError {
                var regError: NSError?
                if let reg = NSRegularExpression(pattern: expectedError, options: NSRegularExpressionOptions(0), error: &regError) {
                    let errorMessage = error.localizedDescription
                    let matches = reg.matchesInString(errorMessage, options: NSMatchingOptions(0), range:NSMakeRange(0, (errorMessage as NSString).length))
                    if countElements(matches) == 0 {
                        XCTFail("`\(errorMessage)` does not match /\(expectedError)/ in \(description)")
                        replayBlock()
                    }
                } else {
                    XCTFail("Invalid expected_error in \(description): \(regError!)")
                    replayBlock()
                }
            } else {
                XCTFail("Unexpected error in \(description): \(error)")
                replayBlock()
            }
        }
        
        func testSuccess(replayOnFailure replayBlock: ()->()) {
            if expectedError != nil {
                XCTFail("Unexpected success in \(description)")
                replayBlock()
            }
        }
        
        func pathsAndEncodingsToPartials(partialsDictionary: [String: String]) -> [(String, NSStringEncoding)] {
            var templatesPaths: [(String, NSStringEncoding)] = []
            
            let fm = NSFileManager.defaultManager()
            var error: NSError?
            let encodings: [NSStringEncoding] = [NSUTF8StringEncoding, NSUTF16StringEncoding]
            for encoding in encodings {
                let templatesPath = NSTemporaryDirectory().stringByAppendingPathComponent("GRMustacheTest").stringByAppendingPathComponent("encoding_\(encoding)")
                if fm.fileExistsAtPath(templatesPath) && !fm.removeItemAtPath(templatesPath, error: &error) {
                    XCTFail("Could not cleanup tests in \(description): \(error!)")
                    return []
                }
                for (partialName, partialString) in partialsDictionary {
                    let partialPath = templatesPath.stringByAppendingPathComponent(partialName)
                    if !fm.createDirectoryAtPath(partialPath.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil, error: &error) {
                        XCTFail("Could not save template in \(description): \(error!)")
                        return []
                    }
                    if !fm.createFileAtPath(partialPath, contents: partialString.dataUsingEncoding(encoding, allowLossyConversion: false), attributes: nil) {
                        XCTFail("Could not save template in \(description): \(error!)")
                        return []
                    }
                }
                
                templatesPaths.append(templatesPath, encoding)
            }
            
            return templatesPaths
        }
    }
}