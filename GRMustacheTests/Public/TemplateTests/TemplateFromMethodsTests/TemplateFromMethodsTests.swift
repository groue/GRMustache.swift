//
//  TemplateFromMethodsTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateFromMethodsTests: XCTestCase {
    
    func inspectFunction(string: String) -> InspectFunction {
        return { (key: String) -> Box? in
            if key == "string" {
                return boxValue(string)
            } else {
                return nil
            }
        }
    }
    
    var testBundle: NSBundle { return NSBundle(forClass: self.dynamicType) }
    
    let templateName = "TemplateFromMethodsTests"
    var templateURL: NSURL { return testBundle.URLForResource(templateName, withExtension: "mustache")! }
    var templatePath: String { return templateURL.path! }
    var templateString: String { return String(contentsOfFile: templatePath, encoding: NSUTF8StringEncoding, error: nil)! }
    
    let parserErrorTemplateName = "TemplateFromMethodsTests_parserError"
    var parserErrorTemplateURL: NSURL { return testBundle.URLForResource(parserErrorTemplateName, withExtension: "mustache")! }
    var parserErrorTemplatePath: String { return parserErrorTemplateURL.path! }
    var parserErrorTemplateString: String { return String(contentsOfFile: parserErrorTemplatePath, encoding: NSUTF8StringEncoding, error: nil)! }
    
    let parserErrorTemplateWrapperName = "TemplateFromMethodsTests_parserErrorWrapper"
    var parserErrorTemplateWrapperURL: NSURL { return testBundle.URLForResource(parserErrorTemplateWrapperName, withExtension: "mustache")! }
    var parserErrorTemplateWrapperPath: String { return parserErrorTemplateWrapperURL.path! }
    var parserErrorTemplateWrapperString: String { return String(contentsOfFile: parserErrorTemplateWrapperPath, encoding: NSUTF8StringEncoding, error: nil)! }
    
    let compilerErrorTemplateName = "TemplateFromMethodsTests_compilerError"
    var compilerErrorTemplateURL: NSURL { return testBundle.URLForResource(compilerErrorTemplateName, withExtension: "mustache")! }
    var compilerErrorTemplatePath: String { return compilerErrorTemplateURL.path! }
    var compilerErrorTemplateString: String { return String(contentsOfFile: compilerErrorTemplatePath, encoding: NSUTF8StringEncoding, error: nil)! }
    
    let compilerErrorTemplateWrapperName = "TemplateFromMethodsTests_compilerErrorWrapper"
    var compilerErrorTemplateWrapperURL: NSURL { return testBundle.URLForResource(compilerErrorTemplateWrapperName, withExtension: "mustache")! }
    var compilerErrorTemplateWrapperPath: String { return compilerErrorTemplateWrapperURL.path! }
    var compilerErrorTemplateWrapperString: String { return String(contentsOfFile: compilerErrorTemplateWrapperPath, encoding: NSUTF8StringEncoding, error: nil)! }
    
    func valueForKey(key: String, inRendering rendering: String) -> AnyObject? {
        let data = rendering.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError?
        let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)!
        return object.valueForKey(key)
    }
    
    func valueForStringPropertyInRendering(rendering: String) -> String? {
        return valueForKey("string", inRendering: rendering) as String?
    }
    
    func extensionOfTemplateFileInRendering(rendering: String) -> String? {
        return (valueForKey("fileName", inRendering: rendering) as String?)?.pathExtension
    }
    
    func testTemplateFromString() {
        let template = Template(string: templateString)!
        let inspect = inspectFunction("foo")
        let rendering = template.render(Box(inspect: inspect))!
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromPath() {
        let template = Template(path: templatePath)!
        let inspect = inspectFunction("foo")
        let rendering = template.render(Box(inspect: inspect))!
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromURL() {
        let template = Template(URL: templateURL)!
        let inspect = inspectFunction("foo")
        let rendering = template.render(Box(inspect: inspect))!
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromResource() {
        let template = Template(named: templateName, bundle: testBundle)!
        let inspect = inspectFunction("foo")
        let rendering = template.render(Box(inspect: inspect))!
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
        XCTAssertEqual(extensionOfTemplateFileInRendering(rendering)!, "mustache")
    }
    
    func testParserErrorFromString() {
        var error: NSError?
        let template = Template(string: parserErrorTemplateString, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    func testParserErrorFromPath() {
        var error: NSError?
        var template = Template(path: parserErrorTemplatePath, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        template = Template(path: parserErrorTemplateWrapperPath, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testParserErrorFromURL() {
        var error: NSError?
        var template = Template(URL: parserErrorTemplateURL, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        template = Template(URL: parserErrorTemplateWrapperURL, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testParserErrorFromResource() {
        var error: NSError?
        var template = Template(named: parserErrorTemplateName, bundle: testBundle, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        template = Template(named: parserErrorTemplateWrapperName, bundle: testBundle, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromString() {
        var error: NSError?
        let template = Template(string: compilerErrorTemplateString, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    func testCompilerErrorFromPath() {
        var error: NSError?
        var template = Template(path: compilerErrorTemplatePath, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        template = Template(path: compilerErrorTemplateWrapperPath, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromURL() {
        var error: NSError?
        var template = Template(URL: compilerErrorTemplateURL, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        template = Template(URL: compilerErrorTemplateWrapperURL, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromResource() {
        var error: NSError?
        var template = Template(named: compilerErrorTemplateName, bundle: testBundle, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        template = Template(named: compilerErrorTemplateWrapperName, bundle: testBundle, error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
}
