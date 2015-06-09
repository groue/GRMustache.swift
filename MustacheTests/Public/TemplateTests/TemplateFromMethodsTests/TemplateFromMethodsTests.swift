// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

class TemplateFromMethodsTests: XCTestCase {
    
    func makeKeyedSubscriptFunction(string: String) -> KeyedSubscriptFunction {
        return { (key: String) -> MustacheBox in
            if key == "string" {
                return Box(string)
            } else {
                return Box()
            }
        }
    }
    
    var testBundle: NSBundle { return NSBundle(forClass: self.dynamicType) }
    
    let templateName = "TemplateFromMethodsTests"
    var templateURL: NSURL { return testBundle.URLForResource(templateName, withExtension: "mustache")! }
    var templatePath: String { return templateURL.path! }
    var templateString: String { return try! String(contentsOfFile: templatePath, encoding: NSUTF8StringEncoding) }
    
    let parserErrorTemplateName = "TemplateFromMethodsTests_parserError"
    var parserErrorTemplateURL: NSURL { return testBundle.URLForResource(parserErrorTemplateName, withExtension: "mustache")! }
    var parserErrorTemplatePath: String { return parserErrorTemplateURL.path! }
    var parserErrorTemplateString: String { return try! String(contentsOfFile: parserErrorTemplatePath, encoding: NSUTF8StringEncoding) }
    
    let parserErrorTemplateWrapperName = "TemplateFromMethodsTests_parserErrorWrapper"
    var parserErrorTemplateWrapperURL: NSURL { return testBundle.URLForResource(parserErrorTemplateWrapperName, withExtension: "mustache")! }
    var parserErrorTemplateWrapperPath: String { return parserErrorTemplateWrapperURL.path! }
    var parserErrorTemplateWrapperString: String { return try! String(contentsOfFile: parserErrorTemplateWrapperPath, encoding: NSUTF8StringEncoding) }
    
    let compilerErrorTemplateName = "TemplateFromMethodsTests_compilerError"
    var compilerErrorTemplateURL: NSURL { return testBundle.URLForResource(compilerErrorTemplateName, withExtension: "mustache")! }
    var compilerErrorTemplatePath: String { return compilerErrorTemplateURL.path! }
    var compilerErrorTemplateString: String { return try! String(contentsOfFile: compilerErrorTemplatePath, encoding: NSUTF8StringEncoding) }
    
    let compilerErrorTemplateWrapperName = "TemplateFromMethodsTests_compilerErrorWrapper"
    var compilerErrorTemplateWrapperURL: NSURL { return testBundle.URLForResource(compilerErrorTemplateWrapperName, withExtension: "mustache")! }
    var compilerErrorTemplateWrapperPath: String { return compilerErrorTemplateWrapperURL.path! }
    var compilerErrorTemplateWrapperString: String { return try! String(contentsOfFile: compilerErrorTemplateWrapperPath, encoding: NSUTF8StringEncoding) }
    
    func valueForKey(key: String, inRendering rendering: String) -> AnyObject? {
        let data = rendering.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError?
        let object: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        return object.valueForKey(key)
    }
    
    func valueForStringPropertyInRendering(rendering: String) -> String? {
        return valueForKey("string", inRendering: rendering) as! String?
    }
    
    func extensionOfTemplateFileInRendering(rendering: String) -> String? {
        return (valueForKey("fileName", inRendering: rendering) as! String?)?.pathExtension
    }
    
    func testTemplateFromString() {
        let template = try! Template(string: templateString)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(Box(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromPath() {
        let template = try! Template(path: templatePath)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(Box(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromURL() {
        let template = try! Template(URL: templateURL)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(Box(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromResource() {
        let template = try! Template(named: templateName, bundle: testBundle)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(Box(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
        XCTAssertEqual(extensionOfTemplateFileInRendering(rendering)!, "mustache")
    }
    
    func testParserErrorFromString() {
        var error: NSError?
        let template: Template?
        do {
            template = try Template(string: parserErrorTemplateString)
        } catch var error1 as NSError {
            error = error1
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    func testParserErrorFromPath() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(path: parserErrorTemplatePath, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        do {
            template = try Template(path: parserErrorTemplateWrapperPath, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testParserErrorFromURL() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(URL: parserErrorTemplateURL, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        do {
            template = try Template(URL: parserErrorTemplateWrapperURL, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testParserErrorFromResource() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(named: parserErrorTemplateName, bundle: testBundle, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
        
        do {
            template = try Template(named: parserErrorTemplateWrapperName, bundle: testBundle, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(parserErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromString() {
        var error: NSError?
        let template: Template?
        do {
            template = try Template(string: compilerErrorTemplateString)
        } catch var error1 as NSError {
            error = error1
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    func testCompilerErrorFromPath() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(path: compilerErrorTemplatePath, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        do {
            template = try Template(path: compilerErrorTemplateWrapperPath, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromURL() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(URL: compilerErrorTemplateURL, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        do {
            template = try Template(URL: compilerErrorTemplateWrapperURL, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
    
    func testCompilerErrorFromResource() {
        var error: NSError?
        var template: Template?
        do {
            template = try Template(named: compilerErrorTemplateName, bundle: testBundle, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
        
        do {
            template = try Template(named: compilerErrorTemplateWrapperName, bundle: testBundle, error: &error)
        } catch _ {
            template = nil
        }
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeParseError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString(compilerErrorTemplatePath) != nil)
    }
}
