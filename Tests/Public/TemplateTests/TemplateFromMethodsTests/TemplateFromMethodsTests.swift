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
    
    func makeKeyedSubscriptFunction(_ string: String) -> KeyedSubscriptFunction {
        return { (key: String) -> MustacheBox in
            if key == "string" {
                return Box(string)
            } else {
                return Box()
            }
        }
    }
    
    var testBundle: Bundle { return Bundle(for: type(of: self)) }
    
    let templateName = "TemplateFromMethodsTests"
    var templateURL: URL { return testBundle.url(forResource: templateName, withExtension: "mustache")! }
    var templatePath: String { return templateURL.path }
    var templateString: String { return try! String(contentsOfFile: templatePath, encoding: String.Encoding.utf8) }
    
    let parserErrorTemplateName = "TemplateFromMethodsTests_parserError"
    var parserErrorTemplateURL: URL { return testBundle.url(forResource: parserErrorTemplateName, withExtension: "mustache")! }
    var parserErrorTemplatePath: String { return parserErrorTemplateURL.path }
    var parserErrorTemplateString: String { return try! String(contentsOfFile: parserErrorTemplatePath, encoding: String.Encoding.utf8) }
    
    let parserErrorTemplateWrapperName = "TemplateFromMethodsTests_parserErrorWrapper"
    var parserErrorTemplateWrapperURL: URL { return testBundle.url(forResource: parserErrorTemplateWrapperName, withExtension: "mustache")! }
    var parserErrorTemplateWrapperPath: String { return parserErrorTemplateWrapperURL.path }
    var parserErrorTemplateWrapperString: String { return try! String(contentsOfFile: parserErrorTemplateWrapperPath, encoding: String.Encoding.utf8) }
    
    let compilerErrorTemplateName = "TemplateFromMethodsTests_compilerError"
    var compilerErrorTemplateURL: URL { return testBundle.url(forResource: compilerErrorTemplateName, withExtension: "mustache")! }
    var compilerErrorTemplatePath: String { return compilerErrorTemplateURL.path }
    var compilerErrorTemplateString: String { return try! String(contentsOfFile: compilerErrorTemplatePath, encoding: String.Encoding.utf8) }
    
    let compilerErrorTemplateWrapperName = "TemplateFromMethodsTests_compilerErrorWrapper"
    var compilerErrorTemplateWrapperURL: URL { return testBundle.url(forResource: compilerErrorTemplateWrapperName, withExtension: "mustache")! }
    var compilerErrorTemplateWrapperPath: String { return compilerErrorTemplateWrapperURL.path }
    var compilerErrorTemplateWrapperString: String { return try! String(contentsOfFile: compilerErrorTemplateWrapperPath, encoding: String.Encoding.utf8) }
    
    func valueForKey(_ key: String, inRendering rendering: String) -> AnyObject? {
        let data = rendering.data(using: String.Encoding.utf8)!
        let object: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
        return object.value(forKey: key)
    }
    
    func valueForStringPropertyInRendering(_ rendering: String) -> String? {
        return valueForKey("string", inRendering: rendering) as! String?
    }
    
    func extensionOfTemplateFileInRendering(_ rendering: String) -> String? {
        return (valueForKey("fileName", inRendering: rendering) as! NSString?)?.pathExtension
    }
    
    func testTemplateFromString() {
        let template = try! Template(string: templateString)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(MustacheBox(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromPath() {
        let template = try! Template(path: templatePath)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(MustacheBox(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromURL() {
        let template = try! Template(URL: templateURL)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(MustacheBox(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
    }
    
    func testTemplateFromResource() {
        let template = try! Template(named: templateName, bundle: testBundle)
        let keyedSubscript = makeKeyedSubscriptFunction("foo")
        let rendering = try! template.render(MustacheBox(keyedSubscript: keyedSubscript))
        XCTAssertEqual(valueForStringPropertyInRendering(rendering)!, "foo")
        XCTAssertEqual(extensionOfTemplateFileInRendering(rendering)!, "mustache")
    }
    
    func testParserErrorFromString() {
        do {
            let _ = try Template(string: parserErrorTemplateString)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testParserErrorFromPath() {
        do {
            let _ = try Template(path: parserErrorTemplatePath)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(path: parserErrorTemplateWrapperPath)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testParserErrorFromURL() {
        do {
            let _ = try Template(URL: parserErrorTemplateURL)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(URL: parserErrorTemplateWrapperURL)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testParserErrorFromResource() {
        do {
            let _ = try Template(named: parserErrorTemplateName, bundle: testBundle)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(named: parserErrorTemplateWrapperName, bundle: testBundle)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: parserErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testCompilerErrorFromString() {
        do {
            let _ = try Template(string: compilerErrorTemplateString)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testCompilerErrorFromPath() {
        do {
            let _ = try Template(path: compilerErrorTemplatePath)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(path: compilerErrorTemplateWrapperPath)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testCompilerErrorFromURL() {
        do {
            let _ = try Template(URL: compilerErrorTemplateURL)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(URL: compilerErrorTemplateWrapperURL)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testCompilerErrorFromResource() {
        do {
            let _ = try Template(named: compilerErrorTemplateName, bundle: testBundle)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            let _ = try Template(named: compilerErrorTemplateWrapperName, bundle: testBundle)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.parseError)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
            XCTAssertTrue(error.description.range(of: compilerErrorTemplatePath) != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
}
